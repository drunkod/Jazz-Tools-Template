// tests/test-flow.js
import { spawn } from "child_process";

async function runTest() {
  console.log("🧪 Testing Jazz message flow...");

  // Start server
  console.log("Starting server...");
  const server = spawn("node", ["src/server.js"], {
    env: { ...process.env, SERVER_ACCOUNT_ID: "test_server" }
  });

  server.stdout.on("data", (data) => {
    console.log(`[Server] ${data}`);
  });

  // Wait for server to start
  await new Promise(resolve => setTimeout(resolve, 2000));

  // Run client
  console.log("Running client...");
  const client = spawn("node", ["src/client.js"], {
    env: { ...process.env, CLIENT_ACCOUNT_ID: "test_client" }
  });

  client.stdout.on("data", (data) => {
    console.log(`[Client] ${data}`);
  });

  // Wait for completion
  await new Promise((resolve) => {
    client.on("exit", (code) => {
      if (code === 0) {
        console.log("✅ Test passed!");
      } else {
        console.log("❌ Test failed!");
      }
      server.kill();
      resolve(code);
    });
  });
}

runTest().catch(console.error);
