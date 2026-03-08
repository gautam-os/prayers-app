import '../models/prayer.dart';

const _marutiOriginal = '''॥ मारुती नमस्कार ॥

महारुद्र अवतार हा सूर्यवंशी ।
अनादिनाथ पूर्ण तारकासी ।
असा चैत्र पौर्णिमेचा जन्म झाला ।
नमस्कार माझा त्या मारुतीला ॥

तनु शिवशक्ति असे पूर्ण ज्याचो ।
किती भाग्य वर्ण त्या अंजनीचें ।
त्याच्या भक्तिलागी असा जन्म झाला ।
नमस्कार माझा त्या मारुतीला ॥

मिलायासी जातां त्या भारकरासी तिथें ।
राहु तो येऊनी त्याजपाशी ।
त्याचा चंडकोप मारितां तो पळाला ।
नमस्कार माझा त्या मारुतीला ॥

खरा ब्रह्मचारी मनांत विचारि ।
म्हणोनि त्यया भेटला रावणारी ।
दयासागर भक्तांचें गाऱ्हाणे ।
नमस्कार माझा त्या मारुतीला ॥

सुमित्रासुता लागली शक्ति जेंव्हा ।
धरी रूप अक्राळ विक्राळ तेव्हा ।
गिरी आणुनी शोभे तो उडविला ।
नमस्कार माझा त्या मारुतीला ॥

जगी भीम तो मारुती ब्रह्मचारी ।
समस्तांपुढे तपसी निर्विकारी ।
नमूं जायवालागीं रे मोक्षपंथा ।
नमस्कार माझा त्या हनुमंता ॥''';

const _marutiEnglish = '''|| Maruti Namaskar ||

Maharudra avatar ha suryavamshi
Anadinath purna tarakasi
Asa Chaitra paurnimecha janma jhala
Namaskar majha tya Marutila

Tanu Shivashakti ase purna jyacho
Kiti bhagya varna tya Anjaniche
Tyachya bhaktilagi asa janma jhala
Namaskar majha tya Marutila

Milayasi jata tya bharkarasi tithe
Rahu to yeuni tyajapashi
Tyacha chandrakop marita to palala
Namaskar majha tya Marutila

Khara brahmachari manat vichari
Mhanoni tyaya bhetala Ravanari
Dayasagar bhaktanche garhane
Namaskar majha tya Marutila

Sumitrasuta lagali shakti jevha
Dhari roop akral vikral tevha
Giri anuni shobhe to udavila
Namaskar majha tya Marutila

Jagi bhim to Maruti brahmachari
Samastanpudhe tapasi nirvikari
Namu jayavalagi re mokshapantha
Namaskar majha tya Hanumanta''';

const _marutiOriginalVerses = [
  '॥ मारुती नमस्कार ॥',
  'महारुद्र अवतार हा सूर्यवंशी ।\nअनादिनाथ पूर्ण तारकासी ।\nअसा चैत्र पौर्णिमेचा जन्म झाला ।\nनमस्कार माझा त्या मारुतीला ॥',
  'तनु शिवशक्ति असे पूर्ण ज्याचो ।\nकिती भाग्य वर्ण त्या अंजनीचें ।\nत्याच्या भक्तिलागी असा जन्म झाला ।\nनमस्कार माझा त्या मारुतीला ॥',
  'मिलायासी जातां त्या भारकरासी तिथें ।\nराहु तो येऊनी त्याजपाशी ।\nत्याचा चंडकोप मारितां तो पळाला ।\nनमस्कार माझा त्या मारुतीला ॥',
  'खरा ब्रह्मचारी मनांत विचारि ।\nम्हणोनि त्यया भेटला रावणारी ।\nदयासागर भक्तांचें गाऱ्हाणे ।\nनमस्कार माझा त्या मारुतीला ॥',
  'सुमित्रासुता लागली शक्ति जेंव्हा ।\nधरी रूप अक्राळ विक्राळ तेव्हा ।\nगिरी आणुनी शोभे तो उडविला ।\nनमस्कार माझा त्या मारुतीला ॥',
  'जगी भीम तो मारुती ब्रह्मचारी ।\nसमस्तांपुढे तपसी निर्विकारी ।\nनमूं जायवालागीं रे मोक्षपंथा ।\nनमस्कार माझा त्या हनुमंता ॥',
];

const _marutiEnglishVerses = [
  '|| Maruti Namaskar ||',
  'Maharudra avatar ha suryavamshi\nAnadinath purna tarakasi\nAsa Chaitra paurnimecha janma jhala\nNamaskar majha tya Marutila',
  'Tanu Shivashakti ase purna jyacho\nKiti bhagya varna tya Anjaniche\nTyachya bhaktilagi asa janma jhala\nNamaskar majha tya Marutila',
  'Milayasi jata tya bharkarasi tithe\nRahu to yeuni tyajapashi\nTyacha chandrakop marita to palala\nNamaskar majha tya Marutila',
  'Khara brahmachari manat vichari\nMhanoni tyaya bhetala Ravanari\nDayasagar bhaktanche garhane\nNamaskar majha tya Marutila',
  'Sumitrasuta lagali shakti jevha\nDhari roop akral vikral tevha\nGiri anuni shobhe to udavila\nNamaskar majha tya Marutila',
  'Jagi bhim to Maruti brahmachari\nSamastanpudhe tapasi nirvikari\nNamu jayavalagi re mokshapantha\nNamaskar majha tya Hanumanta',
];

final List<Prayer> allPrayers = [
  const Prayer(
    id: 'maha_mantra',
    title: 'Maha Mantra (Krishna)',
    originalText:
        'Hare Krishna, Hare Krishna\nKrishna Krishna, Hare Hare\nHare Rama, Hare Rama\nRama Rama, Hare Hare',
    englishText: '',
    presetCounts: [11, 54, 108],
    isTeleprompter: false,
    hasTranslation: false,
  ),
  Prayer(
    id: 'maruti_namaskar',
    title: 'मारुती नमस्कार',
    originalText: _marutiOriginal,
    englishText: _marutiEnglish,
    presetCounts: [1, 11, 108],
    isTeleprompter: true,
    hasTranslation: true,
    originalVerses: _marutiOriginalVerses,
    englishVerses: _marutiEnglishVerses,
  ),
  const Prayer(
    id: 'gayatri_mantra',
    title: 'Gayatri Mantra',
    originalText:
        'Aum Bhuur Bhuvah Svah\nTat Savitur Varennyam\nBhargo Devasya Dhiimahi\nDhiyo Yo Nah Pracodayaat',
    englishText: '',
    presetCounts: [11, 21, 54],
    isTeleprompter: false,
    hasTranslation: false,
  ),
];
