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
    const site = new sst.aws.StaticSite("FlutterWeb", {
      path: "..",
      build: {
        command: "flutter build web --release",
        output: "build/web",
      },
      indexPage: "index.html",
      errorPage: "index.html",
    });

    return {
      siteUrl: site.url,
    };
  },
});
