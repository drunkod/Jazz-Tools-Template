# Jazz-Tools Project Template

A minimal template for building distributed applications with [Jazz-Tools](https://jazz.tools).

## 🚀 Quick Start

```bash
# Enter development environment
nix develop

# Install dependencies
pnpm install

# Start local sync server
pnpm start-sync

# In another terminal: start server
pnpm start-server

# In another terminal: run client
pnpm start-client
```

## 📁 Structure

- `src/schema.js` - Jazz data schemas
- `src/server.js` - Server that receives messages
- `src/client.js` - Client that sends messages
- `tests/` - Test files

## 🧪 Testing

```bash
# Run all tests
pnpm test

# Run NixOS tests
nix flake check
```

## 📝 Schema Example

```javascript
// Define your data structure
export const Message = co.map({
  text: z.string(),
  timestamp: z.string(),
});
```

## 🔧 Customization

1. Modify `src/schema.js` to define your data structures
2. Update `src/server.js` to handle your business logic
3. Adapt `src/client.js` for your use case
4. Add tests in `tests/`
