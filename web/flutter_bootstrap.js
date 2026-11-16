{{flutter_js}}
{{flutter_build_config}}

// Serve the engine's fallback font (Roboto) from this site instead of
// fonts.gstatic.com, so the app makes no third-party requests (see CSP).
_flutter.loader.load({
  config: { fontFallbackBaseUrl: "fonts/" },
});
