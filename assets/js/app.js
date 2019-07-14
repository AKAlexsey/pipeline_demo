// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// LiveView
import LiveSocket from "phoenix_live_view"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

// LiveView for IE 11 commented for a while
// import "mdn-polyfills/NodeList.prototype.forEach"
// import "mdn-polyfills/Element.prototype.closest"
// import "mdn-polyfills/Element.prototype.matches"
// import "child-replace-with-polyfill"
// import "url-search-params-polyfill"
// import "formdata-polyfill"
//
// import {LiveSocket} from "phoenix_live_view"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
