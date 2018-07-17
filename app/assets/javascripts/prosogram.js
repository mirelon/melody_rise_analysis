class Prosogram {
  constructor(lines) {
    console.log(lines);
    var f0s = lines.filter(s => s.indexOf("tend") > -1).map(line => parseInt(line.split("	")[2]));
    var maxRise = 0;
    for (var i in f0s) {
      for (var j in f0s) {
        if (j>i) {
          var f0rise = f0s[j] - f0s[i];
          if (f0rise > maxRise) {
            maxRise = f0rise;
          }
        }
      }
    }
    this.f0rise = maxRise;
    this.output = lines.join("\n");
  }

}