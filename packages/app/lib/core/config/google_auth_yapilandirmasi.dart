// Google OAuth Client ID'leri — bunlar SIR DEĞİL (bir istemci uygulamaya
// gömülmek üzere tasarlandılar, backend'deki JWT_SECRET gibi gizli
// tutulması gereken bir şey değil). Web Client ID hem web hem Android
// girişinde `serverClientId` olarak kullanılıyor ki üretilen token'ın
// "audience"ı backend'in kabul ettiği listeyle hep eşleşsin (bkz.
// packages/backend/.env GOOGLE_CLIENT_ID_WEB, aynı değer).
const String googleWebClientId =
    '453158233634-8hs3v1aihvl3j81u1gla4njjp2lsjr45.apps.googleusercontent.com';
