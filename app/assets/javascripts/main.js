/* Copyright 2013 Chris Wilson

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

window.AudioContext = window.AudioContext || window.webkitAudioContext;

var audioContext = new AudioContext();
var audioInput = null,
    realAudioInput = null,
    inputPoint = null,
    audioRecorder = null;
var rafID = null;
var analyserContext = null;
var canvasWidth, canvasHeight;
var recIndex = 0;

/* TODO:

- offer mono option
- "Monitor input" switch
*/

function saveAudio() {
    audioRecorder.exportWAV( doneEncoding );
    // could get mono instead by saying
    // audioRecorder.exportMonoWAV( doneEncoding );
}

function gotBuffers( buffers ) {
    var canvas = document.getElementById( "wavedisplay" );

    drawBuffer( canvas.width, canvas.height, canvas.getContext('2d'), buffers[0] );

    // the ONLY time gotBuffers is called is right after a new recording is completed - 
    // so here's where we should set up the download.
    audioRecorder.exportWAV( doneEncoding );
}

function doneEncoding( blob ) {
    Recorder.setupDownload( blob, "myRecording" + ((recIndex<10)?"0":"") + recIndex + ".wav" );
    uploadAudio(blob);
    recIndex++;
}

function uploadAudio( blob ) {
  $('#analysisResult').hide();
  $('#loader').show();
  var reader = new FileReader();
  reader.onload = function(event){
    var fd = {};
    console.log(event.target);
    fd["fname"] = "test.wav";
    fd["data"] = event.target.result;
    fd["meno"] = $('#meno').val();
    fd["priezvisko"] = $('#priezvisko').val();
    fd["vek"] = $('#vek').val();
    fd["pohlavie"] = $('#pohlavie').val();
    $.ajax({
      type: 'POST',
      url: '/home/upload',
      data: fd,
      dataType: 'json'
    }).done(function(json) {
      $('#recordingFiles')
        .append($('<option></option>')
        .attr("value",json['id'])
        .text(json['id']));
      $('#recordingFiles').val(json['id']).trigger('change');
    });
  };
  reader.readAsDataURL(blob);
}

function displayAnalysis(data) {
  var canvas = document.getElementById( "wavedisplay" );
  var context = canvas.getContext('2d');
  var width = canvas.width;
  var height = canvas.height;
  context.clearRect(0,0,width,height);
  if (data == undefined) return;
  var recording = new Recording(data);
  console.log(data);
  console.log(recording);
  widthOfOneSecond = Math.ceil( width / recording.duration);
  context.fillStyle = "#006600"; 
  var meanInten = canvas.height / 2 * 2 ** (recording.meanIntensity / 10) / 2 ** (recording.maxIntensity / 10);
  context.fillRect(widthOfOneSecond * recording.startVoiced, canvas.height / 2 - recording.meanInten, widthOfOneSecond * recording.durationVoiced, recording.meanInten * 2); 
  
  for (i in recording.intensity) {
    if (recording.intensity[i] > 0) {
      inten = canvas.height / 2 * 2 ** (recording.intensity[i] / 10) / 2 ** (recording.maxIntensity / 10);
    } else {
      inten = 0;
    }
    if (recording.noise[i] == "0")context.fillStyle = "silver";
    else context.fillStyle = "#aa4444";
    context.fillRect(widthOfOneSecond * (i * recording.basicInterval + recording.startVoiced), canvas.height / 2 - inten, widthOfOneSecond * recording.basicInterval / 2, inten * 2);
  }
  var heightOfHz = canvas.height / recording.diffF0;
  for (i in recording.f0) {
    next = parseInt(i) + 1;
    if (!isNaN(recording.f0[i]) && !isNaN(recording.f0[next])) {
      context.beginPath();
      context.strokeStyle = "#ffff00";
      if (recording.noise[i] == 1) {
        context.strokeStyle = "#ff3300";
      }
      context.lineWidth = 10;
      context.lineCap = "round";
      context.moveTo(widthOfOneSecond * (i * recording.basicInterval + recording.startVoiced),      canvas.height - heightOfHz * (recording.f0[i] - recording.minF0));
      context.lineTo(widthOfOneSecond * ((next) * recording.basicInterval + recording.startVoiced), canvas.height - heightOfHz * (recording.f0[next] - recording.minF0));
      context.stroke();
    }
  }
  arrowHtml = '<div href="#" class="arrow arrow-right">+' + recording.risePercent + '%</div>';
  $('#analysisResult').html(recording.riseFrom + "Hz" + arrowHtml + recording.riseTo + "Hz");
}

function toggleRecording( e ) {
    if (e.classList.contains("recording")) {
        // stop recording
        audioRecorder.stop();
        e.classList.remove("recording");
        audioRecorder.getBuffers( gotBuffers );
    } else {
        // start recording
        if (!audioRecorder)
            return;
        e.classList.add("recording");
        audioRecorder.clear();
        audioRecorder.record();
    }
}

function convertToMono( input ) {
    var splitter = audioContext.createChannelSplitter(2);
    var merger = audioContext.createChannelMerger(2);

    input.connect( splitter );
    splitter.connect( merger, 0, 0 );
    splitter.connect( merger, 0, 1 );
    return merger;
}

function cancelAnalyserUpdates() {
    window.cancelAnimationFrame( rafID );
    rafID = null;
}

function updateAnalysers(time) {
    if (!analyserContext) {
        var canvas = document.getElementById("analyser");
        canvasWidth = canvas.width;
        canvasHeight = canvas.height;
        analyserContext = canvas.getContext('2d');
    }

    // analyzer draw code here
    {
        var SPACING = 3;
        var BAR_WIDTH = 1;
        var numBars = Math.round(canvasWidth / SPACING);
        var freqByteData = new Uint8Array(analyserNode.frequencyBinCount);

        analyserNode.getByteFrequencyData(freqByteData); 

        analyserContext.clearRect(0, 0, canvasWidth, canvasHeight);
        analyserContext.fillStyle = '#F6D565';
        analyserContext.lineCap = 'round';
        var multiplier = analyserNode.frequencyBinCount / numBars;

        // Draw rectangle for each frequency bin.
        for (var i = 0; i < numBars; ++i) {
            var magnitude = 0;
            var offset = Math.floor( i * multiplier );
            // gotta sum/average the block, or we miss narrow-bandwidth spikes
            for (var j = 0; j< multiplier; j++)
                magnitude += freqByteData[offset + j];
            magnitude = magnitude / multiplier;
            var magnitude2 = freqByteData[i * multiplier];
            analyserContext.fillStyle = "hsl( " + Math.round((i*360)/numBars) + ", 100%, 50%)";
            analyserContext.fillRect(i * SPACING, canvasHeight, BAR_WIDTH, -magnitude);
        }
    }
    
    rafID = window.requestAnimationFrame( updateAnalysers );
}

function toggleMono() {
    if (audioInput != realAudioInput) {
        audioInput.disconnect();
        realAudioInput.disconnect();
        audioInput = realAudioInput;
    } else {
        realAudioInput.disconnect();
        audioInput = convertToMono( realAudioInput );
    }

    audioInput.connect(inputPoint);
}

function gotStream(stream) {
    inputPoint = audioContext.createGain();

    // Create an AudioNode from the stream.
    realAudioInput = audioContext.createMediaStreamSource(stream);
    audioInput = realAudioInput;
    audioInput.connect(inputPoint);

//    audioInput = convertToMono( input );

    analyserNode = audioContext.createAnalyser();
    analyserNode.fftSize = 2048;
    inputPoint.connect( analyserNode );

    audioRecorder = new Recorder( inputPoint );

    zeroGain = audioContext.createGain();
    zeroGain.gain.value = 0.0;
    inputPoint.connect( zeroGain );
    zeroGain.connect( audioContext.destination );
    updateAnalysers();
}

function initAudio() {
        if (!navigator.getUserMedia)
            navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
        if (!navigator.cancelAnimationFrame)
            navigator.cancelAnimationFrame = navigator.webkitCancelAnimationFrame || navigator.mozCancelAnimationFrame;
        if (!navigator.requestAnimationFrame)
            navigator.requestAnimationFrame = navigator.webkitRequestAnimationFrame || navigator.mozRequestAnimationFrame;

    navigator.getUserMedia(
        {
            "audio": {
                "mandatory": {
                    "googEchoCancellation": "false",
                    "googAutoGainControl": "false",
                    "googNoiseSuppression": "false",
                    "googHighpassFilter": "false"
                },
                "optional": []
            },
        }, gotStream, function(e) {
            alert('Error getting audio');
            console.log(e);
        });
}

$(function() {
  $('#recordingFiles').on('change', function() {
    if (this.value == 'new') {
      $('#analysis').hide();
      $('#play').hide();
      $('#record').show();
    } else {
      // $('#record').hide();
      $('#analysis').show();
      $('#analysisResult').hide();
      $.ajax({
        type: 'GET',
        url: '/nahravka/' + this.value
      }).done(function(json){
        console.log(json);
        window.json = json;
        $('#play').attr('src', json['wav_url']);
        $('#play').show();
        $('#loader').hide();
        $('#analysisResult').show();
        displayAnalysis(json['praat_output']);
      });
    }   
  });
});

$(function() {
  $('#pacienti').on('change', function() {
    if (this.value == 'new') {
      $('form#pacient')[0].reset();
      $('#meno').focus();
    } else {
      $.ajax({
        type: 'GET',
        url: '/pacient/' + this.value
      }).done(function(json){
        $('#meno').val(json.meno);
        $('#priezvisko').val(json.priezvisko);
        $('#vek').val(json.vek);
        $('#pohlavie').val(json.pohlavie);
      })
    }
  });
});

window.onresize = () => { displayAnalysis(window.data); };
window.addEventListener('load', initAudio );
