# Testing

## E2E

### Playwright

Playwrights' [CDPSession](https://playwright.dev/docs/api/class-cdpsession) and [Network.emulateNetworkConditions](https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-emulateNetworkConditions) in Chrome can be used to simulate slow networks in tests:

```ts
test("Some test broken only in CI's poor network conditions", async ({ context, page }) => {
  const cdpSession = await context.newCDPSession(page);
  await cdpSession.send('Network.emulateNetworkConditions', {
    downloadThroughput: ((500 * 1000) / 8) * 0.8,
    uploadThroughput: ((500 * 1000) / 8) * 0.8,
    latency: 400 * 5,
    offline: false,
  });
 
  // Normal test steps...
```
