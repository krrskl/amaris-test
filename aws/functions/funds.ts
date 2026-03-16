const funds = [
  {
    id: "1",
    name: "FPV_BTG_PACTUAL_RECAUDADORA",
    minimumAmountCop: 75000,
    category: "FPV",
    description: "Voluntary Pension Fund",
  },
  {
    id: "2",
    name: "FPV_BTG_PACTUAL_ECOPETROL",
    minimumAmountCop: 125000,
    category: "FPV",
    description: "Voluntary Pension Fund",
  },
  {
    id: "3",
    name: "DEUDAPRIVADA",
    minimumAmountCop: 50000,
    category: "FIC",
    description: "Collective Investment Fund",
  },
  {
    id: "4",
    name: "FDO-ACCIONES",
    minimumAmountCop: 250000,
    category: "FIC",
    description: "Collective Investment Fund",
  },
  {
    id: "5",
    name: "FPV_BTG_PACTUAL_DINAMICA",
    minimumAmountCop: 100000,
    category: "FPV",
    description: "Voluntary Pension Fund",
  },
];

export const handler = async (
  event: any,
): Promise<{ statusCode: number; headers: Record<string, string>; body: string }> => {
  const requestPath = event?.rawPath ?? event?.requestContext?.http?.path ?? "/";

  if (requestPath !== "/api/funds") {
    return {
      statusCode: 404,
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ message: "Not found" }),
    };
  }

  return {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "public, max-age=300",
    },
    body: JSON.stringify({ data: funds }),
  };
};
