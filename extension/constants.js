const DEFAULT_SETTINGS = {
    serverUrl: 'http://localhost:8765/v1/audio/speech',
    voice: 'bf_lily',
    speed: 1.0,
    recordAudio: false,
    preprocessText: true
  };

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { DEFAULT_SETTINGS };
  } else {
    self.DEFAULT_SETTINGS = DEFAULT_SETTINGS;
  }
