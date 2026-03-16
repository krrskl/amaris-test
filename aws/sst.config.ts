/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app() {
    return {
      name: "amaris-web",
      home: "aws",
      providers: {
        aws: {
          region: process.env.AWS_REGION ?? "us-east-1",
        },
      },
      removal: "retain",
    };
  },
  async run() {
    const fundsApiBaseUrl =
      process.env.FUNDS_API_BASE_URL ??
      "https://6rfe36twk2pwedrwvhevqecome0rmehe.lambda-url.us-east-1.on.aws";

    const fundsApi = new sst.aws.Function("FundsApi", {
      handler: "functions/funds.handler",
      runtime: "nodejs22.x",
      timeout: "10 seconds",
      memory: "128 MB",
      url: true,
    });

    const site = new sst.aws.StaticSite("FlutterWeb", {
      path: "..",
      build: {
        command: `flutter build web --release --dart-define=FUNDS_API_BASE_URL=${fundsApiBaseUrl}`,
        output: "build/web",
      },
      indexPage: "index.html",
      errorPage: "index.html",
      transform: {
        cdn: (args: sst.aws.CdnArgs) => {
          const fundsOrigin = {
            domainName: fundsApi.url.apply((value) => new URL(value).host),
            originId: "funds-api-origin",
            customOriginConfig: {
              httpPort: 80,
              httpsPort: 443,
              originProtocolPolicy: "https-only",
              originSslProtocols: ["TLSv1.2"],
            },
          };

          args.origins = $resolve(args.origins).apply((existing) => [
            ...existing,
            fundsOrigin,
          ]);

          args.orderedCacheBehaviors = $resolve(
            args.orderedCacheBehaviors || [],
          ).apply((existing) => [
            {
              pathPattern: "/api/*",
              targetOriginId: "funds-api-origin",
              viewerProtocolPolicy: "redirect-to-https",
              allowedMethods: ["GET", "HEAD", "OPTIONS"],
              cachedMethods: ["GET", "HEAD"],
              forwardedValues: {
                queryString: true,
                cookies: {
                  forward: "none",
                },
              },
            },
            ...existing,
          ]);
        },
      },
    });

    return {
      siteUrl: site.url,
      fundsApiUrl: fundsApi.url,
    };
  },
});
