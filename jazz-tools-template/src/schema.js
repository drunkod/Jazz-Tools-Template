// src/schema.js
import { co, z } from "jazz-tools";

// Simple message schema
export const Message = co.map({
  text: z.string(),
  timestamp: z.string(),
  from: z.string(),
});

// Account schemas
export const ServerAccount = co.account({
  profile: co.profile({
    name: z.string(),
  }),
  root: co.map({
    messages: co.list(Message),
    messageCount: z.number().optional(),
  }),
});

export const ClientAccount = co.account({
  profile: co.profile({
    name: z.string(),
  }),
  root: co.map({
    sentCount: z.number().optional(),
  }),
});
