// src/server.js
import { startWorker } from "jazz-tools/worker";
import { WebSocket } from "ws";
import { ServerAccount, Message } from "./schema.js";

global.WebSocket = WebSocket;

async function startServer() {
  console.log("🎷 Starting Jazz server...");

  const { worker, experimental: { inbox } } = await startWorker({
    syncServer: process.env.SYNC_URL || "ws://localhost:4200",
    accountID: process.env.SERVER_ACCOUNT_ID || "test_server",
    accountSecret: process.env.SERVER_ACCOUNT_SECRET || "test_secret",
    AccountSchema: ServerAccount,
  });

  // Initialize account
  const account = await worker.ensureLoaded({
    resolve: { profile: true, root: true }
  });

  if (!account.root) {
    account.root = {
      messages: [],
      messageCount: 0
    };
  }

  console.log(`✅ Server ready. ID: ${worker.id}`);

  // Listen for messages
  inbox.subscribe(Message, async (message, senderID) => {
    console.log(`📥 Message from ${senderID}: ${message.text}`);

    // Save message
    account.root.messages.push(message);
    account.root.messageCount = (account.root.messageCount || 0) + 1;
    await account.root.waitForSync();

    console.log(`   Total messages: ${account.root.messageCount}`);
  });
}

startServer().catch(console.error);
