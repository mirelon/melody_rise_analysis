form Text to Speech (eSpeak)
	boolean Prelisten_(press_Apply) 1
	optionmenu Language 25
		option Afrikaans
		option Albanian
		option Amharic
		option Arabic
		option Aragonese
		option Armenian (East Armenia)
		option Armenian (West Armenia)
		option Assamese
		option Azerbaijani
		option Basque
		option Bengali
		option Bishnupriya Manipuri
		option Bosnian
		option Bulgarian
		option Burmese
		option Catalan
		option Chinese (Cantonese)
		option Chinese (Mandarin)
		option Croatian
		option Czech
		option Danish
		option Dutch
		option English (America)
		option English (Caribbean)
		option English (Great Britain)
		option English (Lancaster)
		option English (Received Pronunciation)
		option English (Scotland)
		option English (West Midlands)
		option Esperanto
		option Estonian
		option Finnish
		option French (Belgium)
		option French (France)
		option French (Switzerland)
		option Gaelic (Irish)
		option Gaelic (Scottish)
		option Georgian
		option German
		option Greek
		option Greek (Ancient)
		option Greenlandic
		option Guarani
		option Gujarati
		option Hindi
		option Hungarian
		option Icelandic
		option Indonesian
		option Interlingua
		option Italian
		option Japanese
		option Kannada
		option Konkani
		option Korean
		option Kurdish
		option Kyrgyz
		option Latin
		option Latvian
		option Lingua Franca Nova
		option Lithuanian
		option Lojban
		option Macedonian
		option Malay
		option Malayalam
		option Maltese
		option Marathi
		option Māori
		option Nahuatl (Classical)
		option Nepali
		option Norwegian Bokmål
		option Oriya
		option Oromo
		option Papiamento
		option Persian
		option Persian (Pinglish)
		option Polish
		option Portuguese (Brazil)
		option Portuguese (Portugal)
		option Punjabi
		option Romanian
		option Russian
		option Serbian
		option Setswana
		option Sindhi
		option Sinhala
		option Slovak
		option Slovenian
		option Spanish (Latin America)
		option Spanish (Spain)
		option Swahili
		option Swedish
		option Tamil
		option Tatar
		option Telugu
		option Turkish
		option Urdu
		option Vietnamese (Central)
		option Vietnamese (Northern)
		option Vietnamese (Southern)
		option Welsh
	optionmenu Voice 8
		option Andy
		option Annie
		option AnxiousAndy
		option Auntie
		option Boris
		option Croak
		option Denis
		option Female1
		option Female2
		option Female3
		option Female4
		option Female5
		option Female_whisper
		option Gene
		option Gene2
		option Iven
		option Iven2
		option Iven3
		option Jacky
		option John
		option Kaukovalta
		option Klatt
		option Klatt2
		option Klatt3
		option Klatt4
		option Lee
		option Linda
		option Male1
		option Male2
		option Male3
		option Male4
		option Male5
		option Male6
		option Male7
		option Mario
		option Max
		option Michael
		option Michel
		option Mr_Serious
		option Norbert
		option Quincy
		option Rob
		option Robert
		option Steph
		option Steph2
		option Steph3
		option Storm
		option Travis
		option Tweaky
		option Whisper
		option Zac
	positive Sampling_frequency_(Hz) 44100.0
	real Gap_between_words_(s) 0.01
	positive Pitch_multiplier_(0.5-2.0) 1.0
	real Pitch_range_multiplier_(0-2.0) 1.0
	natural Words_per_minute_(80-450) 175
	comment Text
	text str 1 2 3 4 5
endform
ss = Create SpeechSynthesizer... "'language$'" 'voice$'
if gap_between_words < 0
	gap_between_words = 0
endif
if gap_between_words > 2
	gap_between_words = 2
endif
if pitch_multiplier < 0.5
	pitch_multiplier = 0.5
endif
if pitch_multiplier > 2
	pitch_multiplier = 2
endif
if pitch_range_multiplier < 0
	pitch_range_multiplier = 0
endif
if pitch_range_multiplier > 2
	pitch_range_multiplier = 2
endif
if words_per_minute < 80
	words_per_minute = 80
endif
if words_per_minute > 450
	words_per_minute = 450
endif
Speech output settings... 'sampling_frequency' 'gap_between_words' 'pitch_multiplier' 'pitch_range_multiplier' 'words_per_minute' IPA
if prelisten
	Play text... 'str$'
	Remove
else
	To Sound... "'str$'" no
	s$ = selected$("Sound")
	result = Rename... tts_'s$'
	select ss
	Remove
	select result
endif
