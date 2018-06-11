class Recording {
  constructor(data) {
    var lines = data.split("\n");
    var map = {};
    for (i in lines) {
      var entry = lines[i].split(":");
      map[entry[0]] = entry[1];
    };
    var fullfilename = map["File name"];
    this.filename = fullfilename.substring(fullfilename.lastIndexOf("/") + 1, fullfilename.length);


    // in seconds
    this.duration = parseFloat(map["Duration"]);
    this.basicInterval = parseFloat(map["Basic interval"]);
    this.startVoiced = parseFloat(map["Start voiced"]);
    this.durationVoiced = parseFloat(map["Duration voiced"]);
    this.n = Math.ceil( this.duration / this.basicInterval);
    this.meanIntensity = parseFloat(map["Mean intensity"]);
    this.intensity = [];
    this.f0 = [];
    this.noise = [];
    for (var i = 0; i < this.n; i++) {
      var inten = map["Intensity[" + i + "]"];
      var f0i = map["F0[" + i + "]"];
      var noisei = map["Noise[" + i + "]"];
      if (inten != undefined) this.intensity[i] = parseFloat(inten);
      if (f0i != undefined) this.f0[i] = parseFloat(f0i);
      if (noisei != undefined) this.noise[i] = parseFloat(noisei);
    }
    this.risePercent = parseFloat(map["Rise percent"]);
    this.riseFrom = parseFloat(map["Rise from"]);
    this.riseTo = parseFloat(map["Rise to"]);
   
    this.maxIntensity = 0;
    for (i in this.intensity) {
      if (this.maxIntensity < this.intensity[i]) {
        this.maxIntensity = this.intensity[i];
      }
    }

    this.minF0 = 1000;
    this.maxF0 = 0;
    for (i in this.f0) {
      if (this.noise[i] == "0") {
        if (this.f0[i] < this.minF0) this.minF0 = this.f0[i];
        if (this.f0[i] > this.maxF0) this.maxF0 = this.f0[i];
      }
    }
    this.diffF0 = this.maxF0 - this.minF0;
  }
}