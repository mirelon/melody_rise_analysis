form Sound file name
    sentence File_name "test.wav"
endform

writeInfoLine: "File name: ", file_name$
Read from file: file_name$
originalSelection = selected()
start = Get start time
end = Get end time
duration = end - start
appendInfoLine: "Start: ", fixed$(start, 2)
appendInfoLine: "End: ", fixed$(end, 2)
appendInfoLine: "Duration: ", fixed$(duration, 2)
include voiced.praat
voicedSelection = selected()
startVoiced = Get start time
startVoiced = Get nearest zero crossing... 1 startVoiced
endVoiced = Get end time
endVoiced = Get nearest zero crossing... 1 endVoiced
durationVoiced = endVoiced - startVoiced
appendInfoLine: "Start voiced: ", fixed$(startVoiced, 2)
appendInfoLine: "End voiced: ", fixed$(endVoiced, 2)
appendInfoLine: "Duration voiced: ", fixed$(durationVoiced, 2)

basicInterval = 0.01
appendInfoLine: "Basic interval: ", basicInterval
@analyzePitch
appendInfoLine: "DataPointsCount: ", dataPointsCount
pitchSelection = selected()
selectObject(voicedSelection)
@analyzeIntensity
@calculateNoise

#appendInfoLine: "dataPointsCount=", dataPointsCount
for i from 0 to dataPointsCount - 1
  appendInfoLine: "F0[", string$(i), "]: ", fixed$(mediansF0[i], 2), " Hz"
  appendInfoLine: "Intensity[", string$(i), "]: " + fixed$(intensities[i], 2) + " dB"
  appendInfoLine: "Noise[", string$(i), "]: ", noise[i]
endfor

minF0UpTo[-1] = 10000
for i from 0 to dataPointsCount - 1
  if mediansF0[i] != undefined and intensities[i] != undefined and intensities[i] > meanIntensity and minF0UpTo[i-1] > mediansF0[i]
    minF0UpTo[i] = mediansF0[i]
  else
    minF0UpTo[i] = minF0UpTo[i-1]
  endif
endfor
maxF0UpFrom[dataPointsCount] = -10000
for i from 0 to dataPointsCount - 1
  index = dataPointsCount - i - 1
  if mediansF0[index] != undefined and intensities[index] != undefined and intensities[index] > meanIntensity and maxF0UpFrom[index + 1] < mediansF0[index]
    maxF0UpFrom[index] = mediansF0[index]
  else
    maxF0UpFrom[index] = maxF0UpFrom[index + 1]
  endif
endfor
maxRiseAbs = -1000
maxRisePercent = -1000
fromHz = 0
toHz = 0
for i from 0 to dataPointsCount - 2
  a = minF0UpTo[i]
  b = maxF0UpFrom[i+1]
  if a != undefined and b != undefined
    #appendInfoLine: "Rise if cut in ", i, ": ", fixed$(b - a, 2), " (", fixed$(100 * (b - a) / a, 0), "%)"
    if b - a > maxRiseAbs
      maxRiseAbs = b - a
      maxRisePercent = 100 * (b - a) / a
      fromHz = a
      toHz = b
    endif
  endif
endfor

appendInfoLine: "Rise from: ", fixed$(fromHz, 2), "Hz"
appendInfoLine: "Rise to: ", fixed$(toHz, 2), "Hz"
appendInfoLine: "Rise ", fixed$(maxRiseAbs, 2), "Hz"
appendInfoLine: "Rise percent: ", fixed$(maxRisePercent, 0), "%"

procedure calculateNoise
    for i from 0 to dataPointsCount - 1
      if mediansF0[i] != undefined and intensities[i] != undefined and intensities[i] > meanIntensity
        noise[i] = 0
      else
        noise[i] = 1
      endif
    endfor
endproc

procedure analyzePitch
    To Pitch: 0.0, 75, 600
    i = 0
    while startVoiced + i * basicInterval < endVoiced
      @analyzePitchInInverval: (startVoiced + i * basicInterval), (startVoiced + (i+1) * basicInterval), i
      i = i + 1
    endwhile
    dataPointsCount = i
endproc


procedure analyzePitchInInverval: t1, t2, i
    #appendInfoLine: ""
    #appendInfoLine: "(", fixed$(t1, 2), "s - ", fixed$(t2, 2), "s)"
    medianF0 = Get quantile: t1, t2, 0.5, "Hertz"
    #mean = Get mean: t1, t2, "Hertz"
    #minPitch = Get minimum: t1, t2, "Hertz", "Parabolic"
    #maxPitch = Get maximum: t1, t2, "Hertz", "Parabolic"
    mediansF0[i] = medianF0
    #appendInfoLine: "(", i, ") Median: ", fixed$(median, 2), " Hz, Mean: ", fixed$(mean, 2), " Hz, Min: ", fixed$(minPitch, 2), " Hz, Max: ", fixed$(maxPitch, 2), " Hz"
endproc

procedure analyzeIntensityInInterval: t1, t2, i
    intensity = Get mean: t1, t2
    if intensity != undefined and intensity > 0
      sumIntensities += exp(ln(2) * intensity / 10)
    endif
    intensities[i] = intensity
    #appendInfoLine: "(", i, ") Mean intensity: ", fixed$(intensity, 2), " dB"
endproc

procedure analyzeIntensity
    To Intensity: 100, 0
    sumIntensities = 0
    for i from 0 to dataPointsCount - 1
      @analyzeIntensityInInterval: (startVoiced + i * basicInterval), (startVoiced + (i+1) * basicInterval), i
    endfor
    appendInfoLine: "Sum intensities: ", sumIntensities
    meanIntensity = ln(sumIntensities / dataPointsCount) * 10 / ln(2)
    appendInfoLine: "Mean intensity: ", meanIntensity
endproc
