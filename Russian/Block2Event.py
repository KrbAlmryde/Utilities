from random import choice
mMD = ['tsenitelya', 'pisatelya', 'obyvatelya', 'pokoritelya', 'sozidatelya', 'slushatelya', 'vykljuchatelya', 'osvezhitelya', 'pravitelya', 'dejatelya', 'dushitelya', 'obvinitelya', 'razrushitelya', 'potrebitelya', 'blagodetelya', 'rastochitelya', 'tselitelyem', 'grabitelyem', 'tsenitelyem', 'pisatelyem', 'obyvatelyem', 'ljubitelyem', 'pokoritelyem', 'sozidatelyem', 'slushatelyem', 'vykljuchatelyem', 'pravitelyem', 'dushitelyem', 'obvinitelyem', 'razrushitelyem', 'potrebitelyem', 'blagodetelyem', 'rastochitelyem', 'kolesnitsaoj']
mMS = ['tsarya', 'fonarya', 'glukharya', 'bezdarya', 'sukharya', 'vikhrya', 'zvonarya', 'janvarya', 'aprelya', 'gosudarya', 'slesarya', 'ijunya', 'injulya', 'tjulya', 'parolya', 'rublya', 'voplyem', 'zveryem', 'bukvaryem', 'tsaryem', 'fonaryem', 'glukharyem', 'bezdaryem', 'vikhryem', 'zvonaryem', 'janvaryem', 'aprelyem', 'slesaryem', 'ijunyem', 'injulyem', 'tjulyem', 'parolyem', 'rublyem', 'Rublyem']
mFS = ['lampaoj', 'kolesnitsau', 'lampau', 'kochergau', 'vdovauu', 'uchenistau', 'prodavshchistau', 'rabotnitsau', 'bolnitsau', 'lyzhitsau', 'voronau', 'koronau', 'lestnitsau', 'oblavau', 'koristau', 'druzhbau', 'sluzhbau', 'lvitsau', 'ulitsau', 'raznitsau', 'vysotau', 'vdovaoj', 'uchenistaoj', 'prodavshchistaoj', 'rabotnitsaoj', 'bolnitsaoj', 'lyzhitsaoj', 'koronaoj', 'lestnitsaoj', 'oblavaoj', 'zabavaoj', 'koristaoj', 'druzhbaoj', 'sluzhbaoj', 'lvitsaoj', 'ulitsaoj', 'raznitsaoj', 'vysotaoj', 'zverya']
mFD = ['pogremushkau', 'sobakaoj', 'babushkaoj', 'verjovkaoj', 'pokhodkaoj', 'karameljkaoj', 'devushkaoj', 'rodinkaoj', 'snezhinkaoj', 'vetochkaoj', 'devochkaoj', 'khlopushkaoj', 'petrushkaoj', 'trubochkaoj', 'podushkaoj', 'jubochkaoj', 'zazhigalkaoj', 'makushkaoj', 'skamejkau', 'sobakau', 'babushkau', 'obertkau', 'pokhodkau', 'karameljka', 'rodinkau', 'snezhinkau', 'vetochkau', 'devochkau', 'khlopushkau', 'petrushkau', 'trubochkau', 'podushkau', 'jubochkau', 'zazhigalkau', 'makushkau', 'grabitelya']

fMD = ['voditelya', 'dvigatelya', 'spasitelya', 'khranitelya', 'pokupatelya', 'smotritelya', 'sozdatelya', 'sluzhitelya', 'osnovatelya', 'muchitelya', 'predatelya', 'staratelya', 'mechtatelya', 'tselitelya', 'uchitelyem', 'stroitelyem', 'voditelyem', 'dvigatelyem', 'spasitelyem', 'khranitelyem', 'smotritelyem', 'sozdatelyem', 'sluzhitelyem', 'osnovatelyem', 'roditelyem', 'muchitelyem', 'predatelyem', 'staratelyem', 'mechtatelyem', 'stranistsaoj']
fMS = ['konya', 'denya', 'ogonya', 'penya', 'kamenya', 'olenya', 'shampunya', 'portfelya', 'korablya', 'jantarya', 'ryttsarya', 'vratarya', 'binoklya', 'voplya', 'konyem', 'denyem', 'ogonyem', 'penyem', 'kamenyem', 'olenyem', 'urovenyem', 'shampunyem', 'portfelyem', 'kartofelyem', 'korablyem', 'jantaryem', 'ryttsaryem', 'vrataryem', 'binoklyem', 'pogremushkaoj']
fFS = ['gazetaoj', 'gazetau', 'monetau', 'komnataoj', 'komnatau', 'zhenschinaoj', 'zhenschinau', 'chistotaoj', 'karataoj', 'karatau', 'raketaoj', 'raketau', 'krasotau', 'dorogaoj', 'dorogau', 'pogodaoj', 'pogodau', 'krazhaoj', 'krazhau', 'kryshaoj', 'kryshau', 'roshchaoj', 'roshchau', 'tysjachaoj', 'tysjachau', 'kozhaoj', 'kozhau', 'kochergaoj', 'korenya']
fFD = ['telnjashkau', 'rubashkaoj', 'rubashkau', 'konfetkaoj', 'konfetkau', 'blondinkaoj', 'blondinkau', 'brujunetkaoj', 'brujunetkau', 'brjunetkau', 'vorovkaoj', 'vorovkau', 'vetrovkaoj', 'vetrovkau', 'skovorodkaoj', 'skovorodkau', 'dvukhvostkaoj', 'dvukhvostkau', 'kodirovkaoj', 'kodirovkau', 'tarelkau', 'makakaoj', 'vystavkaoj', 'vystavkau', 'progulkaoj', 'progulkau', 'rozochkaoj', 'rozochkau', 'skamejkaoj', 'uchitelya']

stimOrd = open('Stim_order.txt')
stimList = open('StimulusList.txt', 'a')
stimListPath = open('StimulusListPath.txt', 'a')

MMasc = 'Male/Masculine/'
MFem = 'Male/Feminine/'
FMasc = 'Female/Masculine/'
FFem = 'Female/Feminine/'
wav = '.wav\n'

for stim in stimOrd:
    if 'm1' in stim:
        index = mMD.index(choice(mMD))
        word = mMD.pop(index)
        stimList.write(word + wav)
        stimListPath.write(MMasc + word + wav)

    elif 'm2' in stim:
        index = mMS.index(choice(mMS))
        word = mMS.pop(index)
        stimList.write(word + wav)
        stimListPath.write(MMasc + word + wav)

    elif 'm3' in stim:
        index = mFS.index(choice(mFS))
        word = mFS.pop(index)
        stimList.write(word + wav)
        stimListPath.write(MFem + word + wav)

    elif 'm4' in stim:
        index = mFD.index(choice(mFD))
        word = mFD.pop(index)
        stimList.write(word + wav)
        stimListPath.write(MFem + word + wav)

    elif 'f1' in stim:
        index = fMD.index(choice(fMD))
        word = fMD.pop(index)
        stimList.write(word + wav)
        stimListPath.write(FMasc + word + wav)

    elif 'f2' in stim:
        index = fMS.index(choice(fMS))
        word = fMS.pop(index)
        stimList.write(word + wav)
        stimListPath.write(FMasc + word + wav)

    elif 'f3' in stim:
        index = fFD.index(choice(fFD))
        word = fFD.pop(index)
        stimList.write(word + wav)
        stimListPath.write(FFem + word + wav)

    elif 'f4' in stim:
        index = fFS.index(choice(fFS))
        word = fFS.pop(index)
        stimList.write(word + wav)
        stimListPath.write(FFem + word + wav)

    else:
        stimList.write('null\n')
        stimListPath.write('null\n')

stimList.close()
stimListPath.close()
