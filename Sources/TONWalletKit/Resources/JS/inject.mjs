const DEFAULT_DEVICE_INFO = {
  platform: "browser",
  appName: "Wallet",
  appVersion: "1.0.0",
  maxProtocolVersion: 2,
  features: [
    "SendTransaction",
    {
      name: "SendTransaction",
      maxMessages: 1
    }
  ]
};
const DEFAULT_WALLET_INFO = {
  name: "Wallet",
  appName: "Wallet",
  imageUrl: "https://example.com/image.png",
  bridgeUrl: "https://example.com/bridge.png",
  universalLink: "https://example.com/universal-link",
  aboutUrl: "https://example.com/about",
  platforms: ["chrome", "firefox", "safari", "android", "ios", "windows", "macos", "linux"],
  jsBridgeKey: "wallet"
};
function getDeviceInfoWithDefaults(options) {
  const deviceInfo = {
    ...DEFAULT_DEVICE_INFO,
    ...options
  };
  return deviceInfo;
}
function getWalletInfoWithDefaults(options) {
  const walletInfo = {
    ...DEFAULT_WALLET_INFO,
    ...options
  };
  return walletInfo;
}
function validateBridgeConfig(config) {
  if (!config.deviceInfo) {
    throw new Error("deviceInfo is required");
  }
  if (!config.walletInfo) {
    throw new Error("walletInfo is required");
  }
  if (!config.jsBridgeKey || typeof config.jsBridgeKey !== "string") {
    throw new Error("jsBridgeKey must be a non-empty string");
  }
  if (config.protocolVersion < 2) {
    throw new Error("protocolVersion must be at least 2");
  }
}
class TonConnectBridge {
  // Public properties as per TonConnect spec
  deviceInfo;
  walletInfo;
  protocolVersion;
  isWalletBrowser;
  // Private state
  transport;
  eventListeners = [];
  constructor(config, transport) {
    this.deviceInfo = config.deviceInfo;
    this.walletInfo = config.walletInfo;
    this.protocolVersion = config.protocolVersion;
    this.isWalletBrowser = config.isWalletBrowser;
    this.transport = transport;
    this.transport.onEvent((event) => {
      this.notifyListeners(event);
    });
  }
  /**
   * Initiates connect request - forwards to transport
   */
  async connect(protocolVersion, message) {
    if (protocolVersion < 2) {
      throw new Error("Unsupported protocol version");
    }
    return this.transport.send({
      method: "connect",
      params: { protocolVersion, ...message }
    });
  }
  /**
   * Attempts to restore previous connection - forwards to transport
   */
  async restoreConnection() {
    return this.transport.send({
      method: "restoreConnection",
      params: []
    });
  }
  /**
   * Sends a message to the bridge - forwards to transport
   */
  async send(message) {
    return this.transport.send({
      method: "send",
      params: [message]
    });
  }
  /**
   * Registers a listener for events from the wallet
   * Returns unsubscribe function
   */
  listen(callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback must be a function");
    }
    this.eventListeners.push(callback);
    return () => {
      const index = this.eventListeners.indexOf(callback);
      if (index > -1) {
        this.eventListeners.splice(index, 1);
      }
    };
  }
  /**
   * Expose listener count for environments that need to fan-out events across frames.
   */
  hasListeners() {
    return this.eventListeners.length > 0;
  }
  /**
   * Notify all registered listeners of an event
   */
  notifyListeners(event) {
    this.eventListeners.forEach((callback) => {
      try {
        callback(event);
      } catch (error) {
        console.error("TonConnect event listener error:", error);
      }
    });
  }
  /**
   * Check if transport is available
   */
  isTransportAvailable() {
    return this.transport.isAvailable();
  }
  /**
   * Cleanup resources
   */
  destroy() {
    this.eventListeners.length = 0;
    this.transport.destroy();
  }
}
const TONCONNECT_BRIDGE_REQUEST = "TONCONNECT_BRIDGE_REQUEST";
const TONCONNECT_BRIDGE_RESPONSE = "TONCONNECT_BRIDGE_RESPONSE";
const TONCONNECT_BRIDGE_EVENT$1 = "TONCONNECT_BRIDGE_EVENT";
const INJECT_CONTENT_SCRIPT = "INJECT_CONTENT_SCRIPT";
const DEFAULT_REQUEST_TIMEOUT$1 = 3e5;
const RESTORE_CONNECTION_TIMEOUT$1 = 1e4;
const SUPPORTED_PROTOCOL_VERSION = 2;
class ExtensionTransport {
  extensionId = null;
  source;
  window;
  pendingRequests = /* @__PURE__ */ new Map();
  eventCallback = null;
  messageListener = null;
  constructor(window2, source) {
    this.window = window2;
    this.source = source;
    this.setupMessageListener();
  }
  /**
   * Setup listener for messages from extension
   */
  setupMessageListener() {
    this.messageListener = (event) => {
      if (event.source !== this.window)
        return;
      const data = event.data;
      if (!data || typeof data !== "object")
        return;
      if (data.type === "INJECT_EXTENSION_ID") {
        this.extensionId = data.extensionId;
        return;
      }
      if (data.type === TONCONNECT_BRIDGE_RESPONSE && data.source === this.source) {
        this.handleResponse(data);
        return;
      }
      if (data.type === TONCONNECT_BRIDGE_EVENT$1 && data.source === this.source) {
        this.handleEvent(data.event);
        return;
      }
    };
    this.window.addEventListener("message", this.messageListener);
  }
  /**
   * Handle response from extension
   */
  handleResponse(data) {
    const pendingRequest = this.pendingRequests.get(data.messageId);
    if (!pendingRequest)
      return;
    const { resolve, reject, timeoutId } = pendingRequest;
    this.pendingRequests.delete(data.messageId);
    clearTimeout(timeoutId);
    if (data.success) {
      resolve(data.payload);
    } else {
      reject(data.error);
    }
  }
  /**
   * Handle event from extension
   */
  handleEvent(event) {
    if (this.eventCallback) {
      try {
        this.eventCallback(event);
      } catch (error) {
        console.error("TonConnect event callback error:", error);
      }
    }
  }
  /**
   * Send request to extension
   */
  async send(request) {
    if (!this.isAvailable()) {
      throw new Error("Chrome extension transport is not available");
    }
    return new Promise((resolve, reject) => {
      const messageId = crypto.randomUUID();
      const timeout = request.method === "restoreConnection" ? RESTORE_CONNECTION_TIMEOUT$1 : DEFAULT_REQUEST_TIMEOUT$1;
      const timeoutId = setTimeout(() => {
        if (this.pendingRequests.has(messageId)) {
          this.pendingRequests.delete(messageId);
          reject(new Error(`Request timeout: ${request.method}`));
        }
      }, timeout);
      this.pendingRequests.set(messageId, { resolve, reject, timeoutId });
      try {
        chrome.runtime.sendMessage(this.extensionId, {
          type: TONCONNECT_BRIDGE_REQUEST,
          source: this.source,
          payload: request,
          messageId
        });
      } catch (error) {
        this.pendingRequests.delete(messageId);
        clearTimeout(timeoutId);
        reject(error);
      }
    });
  }
  /**
   * Register event callback
   */
  onEvent(callback) {
    this.eventCallback = callback;
  }
  /**
   * Check if transport is available
   */
  isAvailable() {
    return typeof chrome !== "undefined" && this.extensionId !== null;
  }
  /**
   * Request content script injection for iframes
   */
  requestContentScriptInjection() {
    if (!this.isAvailable())
      return;
    try {
      chrome.runtime.sendMessage(this.extensionId, {
        type: INJECT_CONTENT_SCRIPT
      });
    } catch (error) {
      console.error("Failed to request content script injection:", error);
    }
  }
  /**
   * Cleanup resources
   */
  destroy() {
    this.pendingRequests.forEach(({ timeoutId }) => clearTimeout(timeoutId));
    this.pendingRequests.clear();
    if (this.messageListener) {
      this.window.removeEventListener("message", this.messageListener);
      this.messageListener = null;
    }
    this.eventCallback = null;
    this.extensionId = null;
  }
}
class WindowAccessor {
  window;
  bridgeKey;
  injectTonKey;
  constructor(window2, { bridgeKey, injectTonKey }) {
    this.window = window2;
    this.bridgeKey = bridgeKey;
    this.injectTonKey = injectTonKey ?? true;
  }
  /**
   * Check if bridge already exists
   */
  exists() {
    const windowObj = this.window;
    return !!(windowObj[this.bridgeKey] && windowObj[this.bridgeKey].tonconnect);
  }
  /**
   * Get bridge key name
   */
  getBridgeKey() {
    return this.bridgeKey;
  }
  get tonKey() {
    return "ton";
  }
  /**
   * Ensure wallet object exists on window
   */
  ensureWalletObject() {
    const windowObj = this.window;
    if (!windowObj[this.bridgeKey]) {
      windowObj[this.bridgeKey] = {};
    }
    if (this.injectTonKey) {
      if (!windowObj[this.tonKey]) {
        windowObj[this.tonKey] = {};
      }
    }
  }
  /**
   * Inject bridge into window object
   */
  injectBridge(bridge) {
    this.ensureWalletObject();
    const windowObj = this.window;
    Object.defineProperty(windowObj[this.bridgeKey], "tonconnect", {
      value: bridge,
      writable: false,
      enumerable: true,
      configurable: false
    });
    if (this.injectTonKey) {
      Object.defineProperty(windowObj[this.tonKey], "tonconnect", {
        value: bridge,
        writable: false,
        enumerable: true,
        configurable: false
      });
    }
  }
}
function resolveJsBridgeKey(options) {
  if (options.jsBridgeKey) {
    return options.jsBridgeKey;
  }
  if (options.walletInfo) {
    if ("jsBridgeKey" in options.walletInfo) {
      return options.walletInfo.jsBridgeKey;
    }
    if ("name" in options.walletInfo) {
      return options.walletInfo.name;
    }
  }
  return "unknown-wallet";
}
function createBridgeConfig(options) {
  const deviceInfo = getDeviceInfoWithDefaults(options.deviceInfo);
  const walletInfo = getWalletInfoWithDefaults(options.walletInfo);
  const jsBridgeKey = resolveJsBridgeKey(options);
  return {
    deviceInfo,
    walletInfo,
    jsBridgeKey,
    isWalletBrowser: options.isWalletBrowser ?? false,
    protocolVersion: SUPPORTED_PROTOCOL_VERSION
  };
}
function injectBridge(window2, options, argsTransport) {
  const config = createBridgeConfig(options);
  validateBridgeConfig(config);
  let shouldInjectTonKey = void 0;
  if (options.injectTonKey !== void 0) {
    shouldInjectTonKey = options.injectTonKey;
  } else if (options.isWalletBrowser === true) {
    shouldInjectTonKey = true;
  } else {
    shouldInjectTonKey = true;
  }
  const windowAccessor = new WindowAccessor(window2, {
    bridgeKey: config.jsBridgeKey,
    injectTonKey: shouldInjectTonKey
  });
  if (windowAccessor.exists()) {
    console.log(`${config.jsBridgeKey}.tonconnect already exists, skipping injection`);
    return;
  }
  let transport;
  if (argsTransport) {
    transport = argsTransport;
  } else {
    const source = `${config.jsBridgeKey}-tonconnect`;
    transport = new ExtensionTransport(window2, source);
  }
  const bridge = new TonConnectBridge(config, transport);
  windowAccessor.injectBridge(bridge);
  console.log(`TonConnect JS Bridge injected for ${config.jsBridgeKey} - forwarding to extension`);
  return;
}
function injectBridgeCode(window2, options, transport) {
  injectBridge(window2, options, transport);
}
const TONCONNECT_BRIDGE_EVENT = "TONCONNECT_BRIDGE_EVENT";
const DEFAULT_REQUEST_TIMEOUT = 3e5;
const RESTORE_CONNECTION_TIMEOUT = 1e4;
var __defProp = Object.defineProperty;
var __defProps = Object.defineProperties;
var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
var __getOwnPropSymbols = Object.getOwnPropertySymbols;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __propIsEnum = Object.prototype.propertyIsEnumerable;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __spreadValues = (a, b) => {
  for (var prop in b || (b = {}))
    if (__hasOwnProp.call(b, prop))
      __defNormalProp(a, prop, b[prop]);
  if (__getOwnPropSymbols)
    for (var prop of __getOwnPropSymbols(b)) {
      if (__propIsEnum.call(b, prop))
        __defNormalProp(a, prop, b[prop]);
    }
  return a;
};
var __spreadProps = (a, b) => __defProps(a, __getOwnPropDescs(b));
var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);
var __async = (__this, __arguments, generator) => {
  return new Promise((resolve, reject) => {
    var fulfilled = (value) => {
      try {
        step(generator.next(value));
      } catch (e) {
        reject(e);
      }
    };
    var rejected = (value) => {
      try {
        step(generator.throw(value));
      } catch (e) {
        reject(e);
      }
    };
    var step = (x) => x.done ? resolve(x.value) : Promise.resolve(x.value).then(fulfilled, rejected);
    step((generator = generator.apply(__this, __arguments)).next());
  });
};
window.injectWalletKit = (options) => {
  try {
    injectBridgeCode(window, options, new SwiftTransport(window));
    console.log("TonConnect bridge injected - forwarding to extension");
  } catch (error) {
    console.error("Failed to inject TonConnect bridge:", error);
  }
};
window.id = crypto.randomUUID();
class SwiftTransport {
  constructor(window2) {
    __publicField(this, "window");
    __publicField(this, "eventCallback", null);
    __publicField(this, "messageListener", null);
    this.window = window2;
    this.setupMessageListener();
  }
  setupMessageListener() {
    this.messageListener = (event) => {
      if (event.source !== this.window) return;
      const data = event.data;
      if (!data || typeof data !== "object") return;
      if (data.type === TONCONNECT_BRIDGE_EVENT) {
        this.handleEvent(data.event);
        return;
      }
    };
    this.window.addEventListener("message", this.messageListener);
  }
  handleEvent(event) {
    if (this.eventCallback) {
      try {
        this.eventCallback(event);
      } catch (error) {
        console.error("TonConnect event callback error:", error);
      }
    }
  }
  send(request) {
    return __async(this, null, function* () {
      let timeout = request.method === "restoreConnection" ? RESTORE_CONNECTION_TIMEOUT : DEFAULT_REQUEST_TIMEOUT;
      let response = yield window.webkit.messageHandlers.walletKitInjectionBridge.postMessage(
        __spreadProps(__spreadValues({}, request), { frameID: window.id, timeout })
      );
      console.log("SwiftTransport received response:", response);
      if (response.success) {
        return Promise.resolve(response.payload);
      } else {
        return Promise.reject(response.error);
      }
    });
  }
  onEvent(callback) {
    this.eventCallback = callback;
  }
  isAvailable() {
    return true;
  }
  requestContentScriptInjection() {
  }
  destroy() {
  }
}
//# sourceMappingURL=inject.mjs.map
