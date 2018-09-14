transformations = {
    'Banícky banán bude anulovať bombu' => 'Bude banícky banán anulovať bombu?',
    'Boris asi dal aj branné cvičenie' => 'Dal Boris aj branné cvičenie?',
    'Drevorubač búral dvojmo celé dni' => 'Búral drevorubač dvojmo celé dni?',
    'Exprezident ešte dýcha' => 'Dýcha exprezident ešte?',
    'Dievča farbí červenú dúhu' => 'Farbí dievča červenú dúhu?',
}

require 'minitest/autorun'

describe 'Sentence::otazka' do
  it 'correctly create question' do
    transformations.each do |oznam, otazka|
      Sentence.new(oznam).otazka.must_equal otazka
    end
  end
end
