// src/client.js
import { startWorker } from "jazz-tools/worker";
import { InboxSender } from "jazz-tools";
import { WebSocket } from "ws";
import { ClientAccount, Message } from "./schema.js";

global.WebSocket = WebSocket;

async function runClient() {
  console.log("📤 Starting Jazz client...");

  const { worker } = await startWorker({
    syncServer: process.env.SYNC_URL || "ws://localhost:4200",
    accountID: process.env.CLIENT_ACCOUNT_ID || "test_client",
    accountSecret: process.env.CLIENT_ACCOUNT_SECRET || "test_secret",
    AccountSchema: ClientAccount,
  });

  // Get server account ID from env or use default
  const serverID = process.env.SERVER_ACCOUNT_ID || "test_server";

  console.log(`🔌 Connecting to server: ${serverID}`);
  const sender = await InboxSender.load(serverID, worker);

  // Send a message
  const message = Message.create({
    text: "Hello from client!",
    timestamp: new Date().toISOString(),
    from: worker.id,
  }, { owner: worker });

  await sender.sendMessage(message);
  console.log("✅ Message sent!");

  // Update client stats
  const account = await worker.ensureLoaded({ resolve: { root: true } });
  if (account.root) {
    account.root.sentCount = (account.root.sentCount || 0) + 1;
  }

  process.exit(0);
}

// Run with delay if needed
setTimeout(runClient, 1000);
