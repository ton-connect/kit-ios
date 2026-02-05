const ERROR_CODES = {
  // Bridge Manager Errors (7000-7099)
  BRIDGE_NOT_INITIALIZED: 7e3,
  BRIDGE_CONNECTION_FAILED: 7001,
  BRIDGE_EVENT_PROCESSING_FAILED: 7002,
  BRIDGE_RESPONSE_SEND_FAILED: 7003,
  // Session Errors (7100-7199)
  SESSION_NOT_FOUND: 7100,
  SESSION_ID_REQUIRED: 7101,
  SESSION_CREATION_FAILED: 7102,
  SESSION_DOMAIN_REQUIRED: 7103,
  SESSION_RESTORATION_FAILED: 7104,
  // Event Store Errors (7200-7299)
  EVENT_STORE_NOT_INITIALIZED: 7200,
  EVENT_STORE_OPERATION_FAILED: 7201,
  // Storage Errors (7300-7399)
  STORAGE_READ_FAILED: 7300,
  STORAGE_WRITE_FAILED: 7301,
  // Wallet Errors (7400-7499)
  WALLET_NOT_FOUND: 7400,
  WALLET_REQUIRED: 7401,
  WALLET_INVALID: 7402,
  WALLET_CREATION_FAILED: 7403,
  WALLET_INITIALIZATION_FAILED: 7404,
  LEDGER_DEVICE_ERROR: 7405,
  // Request Processing Errors (7500-7599)
  INVALID_REQUEST_EVENT: 7500,
  REQUEST_PROCESSING_FAILED: 7501,
  RESPONSE_CREATION_FAILED: 7502,
  APPROVAL_FAILED: 7503,
  REJECTION_FAILED: 7504,
  // API Client Errors (7600-7699)
  API_CLIENT_ERROR: 7600,
  TON_CLIENT_INITIALIZATION_FAILED: 7601,
  API_REQUEST_FAILED: 7602,
  ACCOUNT_NOT_FOUND: 7603,
  // Jetton/NFT Errors (7700-7799)
  JETTONS_MANAGER_ERROR: 7700,
  NFT_MANAGER_ERROR: 7701,
  // Contract Errors (7800-7899)
  CONTRACT_DEPLOYMENT_FAILED: 7800,
  CONTRACT_EXECUTION_FAILED: 7801,
  CONTRACT_VALIDATION_FAILED: 7802,
  // Network Errors (7850-7899)
  NETWORK_NOT_CONFIGURED: 7850,
  // Generic Errors (7900-7999)
  UNKNOWN_ERROR: 7900,
  VALIDATION_ERROR: 7901,
  INITIALIZATION_ERROR: 7902,
  CONFIGURATION_ERROR: 7903,
  NETWORK_ERROR: 7904,
  UNKNOWN_EMULATION_ERROR: 7905,
  INVALID_CONFIG: 7906
};
function getErrorCodeName(code) {
  const entry = Object.entries(ERROR_CODES).find(([, value]) => value === code);
  return entry ? entry[0] : `UNKNOWN_CODE_${code}`;
}
class WalletKitError extends Error {
  code;
  codeName;
  originalError;
  context;
  constructor(code, message, originalError, context) {
    const fullMessage = originalError ? `${message}: ${originalError.message}` : message;
    super(fullMessage);
    this.name = "WalletKitError";
    this.code = code;
    this.codeName = getErrorCodeName(code);
    this.originalError = originalError;
    this.context = context;
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, WalletKitError);
    }
    if (originalError?.stack) {
      this.stack = `${this.stack}
Caused by: ${originalError.stack}`;
    }
  }
  /**
   * Create a WalletKitError from an unknown error
   */
  static fromError(code, message, error, context) {
    if (error instanceof Error) {
      return new WalletKitError(code, message, error, context);
    }
    const errorMessage = error && typeof error === "object" && "message" in error ? String(error.message) : String(error);
    return new WalletKitError(code, `${message}: ${errorMessage}`, void 0, { ...context, originalValue: error });
  }
  /**
   * Check if an error is a WalletKitError with a specific code
   */
  static isWalletKitError(error, code) {
    if (!(error instanceof WalletKitError)) {
      return false;
    }
    if (code !== void 0) {
      return error.code === code;
    }
    return true;
  }
  /**
   * Serialize error to JSON
   */
  toJSON() {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      codeName: this.codeName,
      context: this.context,
      stack: this.stack,
      originalError: this.originalError ? {
        name: this.originalError.name,
        message: this.originalError.message,
        stack: this.originalError.stack
      } : void 0
    };
  }
}
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
  return addLegacySendTransactionFeature(deviceInfo);
}
function getWalletInfoWithDefaults(options) {
  const walletInfo = {
    ...DEFAULT_WALLET_INFO,
    ...options
  };
  return walletInfo;
}
function addLegacySendTransactionFeature(options) {
  const features = options.features;
  const hasSendTransactionString = features.some((feature) => feature === "SendTransaction");
  const hasSendTransactionObject = features.some((feature) => typeof feature === "object" && feature.name === "SendTransaction");
  const shouldAddString = !hasSendTransactionString && hasSendTransactionObject;
  return {
    ...options,
    features: shouldAddString ? ["SendTransaction", ...features] : features
  };
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
  walletId;
  // Private state
  transport;
  eventListeners = [];
  constructor(config, transport) {
    this.deviceInfo = config.deviceInfo;
    this.walletInfo = config.walletInfo;
    this.protocolVersion = config.protocolVersion;
    this.isWalletBrowser = config.isWalletBrowser;
    this.walletId = config.walletId;
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
      params: { protocolVersion, ...message },
      walletId: this.walletId
    });
  }
  /**
   * Attempts to restore previous connection - forwards to transport
   */
  async restoreConnection() {
    return this.transport.send({
      method: "restoreConnection",
      params: [],
      walletId: this.walletId
    });
  }
  /**
   * Sends a message to the bridge - forwards to transport
   */
  async send(message) {
    return this.transport.send({
      method: "send",
      params: [message],
      walletId: this.walletId
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
const DEFAULT_REQUEST_TIMEOUT = 3e5;
const RESTORE_CONNECTION_TIMEOUT = 1e4;
const SUPPORTED_PROTOCOL_VERSION = 2;
class IframeWatcher {
  onIframeDetected;
  observer = null;
  constructor(onIframeDetected) {
    this.onIframeDetected = onIframeDetected;
  }
  /**
   * Start watching for iframes
   */
  start() {
    if (this.observer) {
      return;
    }
    this.observer = new MutationObserver((mutations) => {
      this.handleMutations(mutations);
    });
    this.observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }
  /**
   * Stop watching for iframes
   */
  stop() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
  }
  /**
   * Handle DOM mutations
   */
  handleMutations(mutations) {
    for (const mutation of mutations) {
      if (mutation.type !== "childList") {
        continue;
      }
      for (const node of mutation.addedNodes) {
        this.handleAddedNode(node);
      }
    }
  }
  /**
   * Handle a single added node
   */
  handleAddedNode(node) {
    if (node.nodeType !== Node.ELEMENT_NODE) {
      return;
    }
    const element = node;
    if (element.tagName === "IFRAME") {
      this.setupIframeListeners(element);
      this.onIframeDetected();
      return;
    }
    const iframes = element.querySelectorAll("iframe");
    if (iframes.length > 0) {
      iframes.forEach((iframe) => {
        this.setupIframeListeners(iframe);
      });
      this.onIframeDetected();
    }
  }
  /**
   * Setup event listeners for iframe
   */
  setupIframeListeners(iframe) {
    const handleIframeEvent = () => {
      this.onIframeDetected();
    };
    iframe.removeEventListener("load", handleIframeEvent);
    iframe.removeEventListener("error", handleIframeEvent);
    iframe.addEventListener("load", handleIframeEvent);
    iframe.addEventListener("error", handleIframeEvent);
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
    protocolVersion: SUPPORTED_PROTOCOL_VERSION,
    walletId: options.walletId
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
    transport = typeof argsTransport === "function" ? argsTransport() : argsTransport;
  } else {
    throw new WalletKitError(ERROR_CODES.INVALID_CONFIG, "Transport is not configured");
  }
  const bridge = new TonConnectBridge(config, transport);
  windowAccessor.injectBridge(bridge);
  console.log(`TonConnect JS Bridge injected for ${config.jsBridgeKey} - forwarding to extension`);
  const iframeWatcher = new IframeWatcher(() => {
    transport.requestContentScriptInjection();
  });
  iframeWatcher.start();
  return;
}
const TONCONNECT_BRIDGE_EVENT = "TONCONNECT_BRIDGE_EVENT";
var LogLevel;
(function(LogLevel2) {
  LogLevel2[LogLevel2["DEBUG"] = 0] = "DEBUG";
  LogLevel2[LogLevel2["INFO"] = 1] = "INFO";
  LogLevel2[LogLevel2["WARN"] = 2] = "WARN";
  LogLevel2[LogLevel2["ERROR"] = 3] = "ERROR";
  LogLevel2[LogLevel2["NONE"] = 4] = "NONE";
})(LogLevel || (LogLevel = {}));
class Logger {
  config;
  parent;
  static defaultConfig = {
    level: LogLevel.INFO,
    prefix: "TonWalletKit",
    enableTimestamp: true,
    enableStackTrace: false
  };
  constructor(config) {
    this.parent = config?.parent;
    this.config = { ...Logger.defaultConfig, ...config };
    if (this.parent) {
      this.config = {
        ...this.parent.config,
        ...config,
        // Build hierarchical prefix
        prefix: this.buildHierarchicalPrefix(config?.prefix)
      };
    }
  }
  /**
   * Update logger configuration
   */
  configure(config) {
    this.config = { ...this.config, ...config };
  }
  /**
   * Create a child logger with a prefix that inherits from this logger
   */
  createChild(prefix, config) {
    return new Logger({
      ...config,
      parent: this,
      prefix
    });
  }
  /**
   * Build hierarchical prefix by combining parent prefix with current prefix
   */
  buildHierarchicalPrefix(currentPrefix) {
    if (!this.parent || !currentPrefix) {
      return currentPrefix || this.parent?.config.prefix || "";
    }
    const parentPrefix = this.parent.config.prefix;
    if (!parentPrefix) {
      return currentPrefix;
    }
    return `${parentPrefix}:${currentPrefix}`;
  }
  /**
   * Get the full hierarchical prefix for this logger
   */
  getPrefix() {
    return this.config.prefix || "";
  }
  /**
   * Get the parent logger if it exists
   */
  getParent() {
    return this.parent;
  }
  /**
   * Log debug messages
   */
  debug(message, context) {
    if (this.config.level <= LogLevel.DEBUG) {
      this.log("DEBUG", message, context);
    }
  }
  /**
   * Log info messages
   */
  info(message, context) {
    if (this.config.level <= LogLevel.INFO) {
      this.log("INFO", message, context);
    }
  }
  /**
   * Log warning messages
   */
  warn(message, context) {
    if (this.config.level <= LogLevel.WARN) {
      this.log("WARN", message, context);
    }
  }
  /**
   * Log error messages
   */
  error(message, context) {
    if (this.config.level <= LogLevel.ERROR) {
      this.log("ERROR", message, context);
    }
  }
  /**
   * Internal logging method
   */
  log(level, message, context) {
    const timestamp = this.config.enableTimestamp ? (/* @__PURE__ */ new Date()).toISOString() : "";
    const prefix = this.config.prefix ? `[${this.config.prefix}]` : "";
    let logMessage = "";
    if (timestamp) {
      logMessage += `${timestamp} `;
    }
    if (prefix) {
      logMessage += `${prefix} `;
    }
    logMessage += `${level}: ${message}`;
    const logArgs = [logMessage];
    if (context && Object.keys(context).length > 0) {
      logArgs.push(context);
    }
    switch (level) {
      case "DEBUG":
        console.debug(...logArgs);
        break;
      case "INFO":
        console.info(...logArgs);
        break;
      case "WARN":
        console.warn(...logArgs);
        break;
      case "ERROR":
        console.error(...logArgs);
        if (this.config.enableStackTrace) {
          console.trace();
        }
        break;
    }
  }
}
const globalLogger = new Logger({
  level: LogLevel.DEBUG,
  enableStackTrace: true
});
globalLogger.createChild("ExtensionTransport");
function injectBridgeCode(window2, options, transport) {
  injectBridge(window2, options, transport);
}
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
  } catch (_error) {
  }
};
window.id = crypto.randomUUID();
class SwiftTransport {
  constructor(window2) {
    this.eventCallback = null;
    this.messageListener = null;
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
      let response = yield window.webkit.messageHandlers.walletKitInjectionBridge.postMessage(__spreadProps(__spreadValues({}, request), {
        frameID: window.id,
        timeout
      }));
      if (!response || typeof response !== "object") {
        return Promise.reject(new Error("Invalid response"));
      }
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
