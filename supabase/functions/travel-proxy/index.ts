const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const openRouterBaseUrl =
  Deno.env.get("OPENROUTER_BASE_URL") ?? "https://openrouter.ai/api/v1";
const openRouterModel =
  Deno.env.get("OPENROUTER_MODEL") ?? "google/gemini-2.5-flash";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(request.url);

  try {
    if (request.method !== "POST") {
      return json({ error: "Only POST is supported" }, 405);
    }

    if (url.pathname.endsWith("/ai/chat")) {
      return await aiChat(request);
    }

    if (url.pathname.endsWith("/ai/complete")) {
      return await aiComplete(request);
    }

    if (url.pathname.endsWith("/serp/search")) {
      return await serpSearch(request);
    }

    return json({ error: "Unknown proxy route" }, 404);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Proxy error";
    return json({ error: message }, 500);
  }
});

async function aiChat(request: Request): Promise<Response> {
  const apiKey = requireEnv("OPENROUTER_API_KEY");
  const body = await request.json();
  const messages = [
    { role: "system", content: String(body.system ?? "") },
    ...(Array.isArray(body.messages) ? body.messages : []),
  ];

  const upstream = await fetch(`${openRouterBaseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://lookstrip.app",
      "X-Title": "LooksTrip",
    },
    body: JSON.stringify({
      model: openRouterModel,
      messages,
      stream: true,
      max_tokens: numberOr(body.max_tokens, 1024),
      temperature: numberOr(body.temperature, 0.7),
    }),
  });

  return new Response(upstream.body, {
    status: upstream.status,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
    },
  });
}

async function aiComplete(request: Request): Promise<Response> {
  const apiKey = requireEnv("OPENROUTER_API_KEY");
  const body = await request.json();

  const upstream = await fetch(`${openRouterBaseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": "https://lookstrip.app",
      "X-Title": "LooksTrip",
    },
    body: JSON.stringify({
      model: openRouterModel,
      messages: [{ role: "user", content: String(body.prompt ?? "") }],
      max_tokens: numberOr(body.max_tokens, 2048),
      temperature: numberOr(body.temperature, 0.7),
    }),
  });

  const data = await upstream.json();
  const content = data?.choices?.[0]?.message?.content ?? "";
  return json({ content }, upstream.status);
}

async function serpSearch(request: Request): Promise<Response> {
  const apiKey = requireEnv("SERPAPI_API_KEY");
  const body = await request.json();
  const params = new URLSearchParams(body.params ?? {});
  params.set("api_key", apiKey);

  const upstream = await fetch(`https://serpapi.com/search.json?${params}`);
  const data = await upstream.json();
  return json(data, upstream.status);
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured on the proxy`);
  return value;
}

function numberOr(value: unknown, fallback: number): number {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}
