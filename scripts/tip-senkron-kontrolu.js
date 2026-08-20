// packages/shared-types/src/*.types.ts (TS) ile packages/app/lib/**/*.dart
// (Dart aynası) arasında ALAN ADI uyumsuzluğu var mı diye bakar.
//
// NEDEN: Flutter geçişinden önce (Expo/RN döneminde) TS derleyicisi ikisini
// de görüp uyuşmazlıkta derleme hatası verebiliyordu. Dart artık TS paketini
// import edemediği için bu otomatik kontrol kayboldu — "disiplinle" (elle
// hatırlayarak) sürdürülüyordu. Bir alan TS'te kaldırılır/adı değişirse Dart
// tarafı hâlâ eski adı okur, JSON'da yoksa çoğu yerde `?? 0` / `?? ''` gibi
// sessizce bir varsayılana düşer — DERLEME HATASI YOK, çoğu zaman test de
// yakalamaz. Bu script tam o riski hedefliyor (izlence Adım 15: "shared-types
// senkron kontrolü").
//
// KAPSAM DIŞI (bilerek): union string tipleri (`type X = 'a' | 'b'` —
// KullaniciRolu, IsIlaniDurumu gibi enum karşılıkları) karşılaştırılmıyor,
// sadece `interface`/Dart `class` alan adları. Enum karşılaştırması farklı
// bir mantık gerektiriyor, ayrı bir iş.
//
// EŞLEŞTİRME KURALI: önce TAM aynı isim aranır (KullaniciOzet ↔ KullaniciOzet
// gibi çoğunluk). Bulunamazsa "Response"/"Request" son eki atılıp tekrar
// denenir (PaletResponse ↔ Palet gibi). O da yoksa aşağıdaki ELLE eşleme
// tablosuna bakılır (isim tamamen farklıysa — IsOrtagiResponse ↔
// IsOrtagiModeli gibi, TAHMİN edilemeyen durumlar). Hiçbiri yoksa o TS
// arayüzünün Dart'ta KASITLI OLARAK mirror edilmediği varsayılır, atlanır
// (hata sayılmaz) — örn. FavoriDurumDegistirRequest, favori_api.dart'ta
// class'sız, doğrudan Map olarak gönderiliyor.
const ELLE_ESLEME = {
  IsOrtagiResponse: 'IsOrtagiModeli',
};

const fs = require('fs');
const path = require('path');
const ts = require('typescript');

const TS_DIR = path.join(__dirname, '..', 'packages', 'shared-types', 'src');
const DART_KOK = path.join(__dirname, '..', 'packages', 'app', 'lib');

function tsArayuzleriniCikar() {
  const ham = new Map(); // isim -> { alanlar: Set, ebeveynler: string[] }
  const dosyalar = fs.readdirSync(TS_DIR).filter((f) => f.endsWith('.types.ts'));

  for (const dosya of dosyalar) {
    const tamYol = path.join(TS_DIR, dosya);
    const kaynak = fs.readFileSync(tamYol, 'utf8');
    const sourceFile = ts.createSourceFile(dosya, kaynak, ts.ScriptTarget.Latest, true);

    ts.forEachChild(sourceFile, (node) => {
      if (!ts.isInterfaceDeclaration(node)) return;
      const isim = node.name.text;
      const alanlar = new Set();
      for (const uye of node.members) {
        if (ts.isPropertySignature(uye) && uye.name) {
          alanlar.add(uye.name.getText(sourceFile));
        }
      }
      const ebeveynler = [];
      for (const clause of node.heritageClauses ?? []) {
        for (const tip of clause.types) {
          ebeveynler.push(tip.expression.getText(sourceFile));
        }
      }
      ham.set(isim, { alanlar, ebeveynler });
    });
  }

  // `extends` zincirini düzleştir (FirmaOnayKuyrugu extends FirmaResponse gibi).
  const duzlestirilmis = new Map();
  function duzlestir(isim, gorulenler = new Set()) {
    if (duzlestirilmis.has(isim)) return duzlestirilmis.get(isim);
    if (gorulenler.has(isim)) return new Set();
    gorulenler.add(isim);
    const kayit = ham.get(isim);
    if (!kayit) return new Set();
    const tumAlanlar = new Set(kayit.alanlar);
    for (const ebeveyn of kayit.ebeveynler) {
      for (const a of duzlestir(ebeveyn, gorulenler)) tumAlanlar.add(a);
    }
    duzlestirilmis.set(isim, tumAlanlar);
    return tumAlanlar;
  }
  for (const isim of ham.keys()) duzlestir(isim);
  return duzlestirilmis;
}

/** `{`/`}` sayarak bir class gövdesinin bittiği yeri bulur — basit ama
 * Dart'ın nested `{}` içeren tipleri (Map<String, dynamic> vb.) için
 * regex'ten daha güvenilir. */
function eslesenKapaniAyracaBul(metin, acilisIndeksi) {
  let derinlik = 0;
  for (let i = acilisIndeksi; i < metin.length; i++) {
    if (metin[i] === '{') derinlik++;
    else if (metin[i] === '}') {
      derinlik--;
      if (derinlik === 0) return i;
    }
  }
  return metin.length - 1;
}

function dartSiniflariniCikar() {
  const sonuc = new Map(); // isim -> Set(alanlar)
  const dosyalar = [];
  (function tara(dizin) {
    for (const girdi of fs.readdirSync(dizin, { withFileTypes: true })) {
      const tamYol = path.join(dizin, girdi.name);
      if (girdi.isDirectory()) tara(tamYol);
      else if (girdi.name.endsWith('.dart')) dosyalar.push(tamYol);
    }
  })(DART_KOK);

  const sinifRegex = /class\s+(\w+)\b[^{]*\{/g;
  // `final <Tip> <isim>;` — tip kısmı generic (<...>) / nullable (?) içerebilir.
  // `get` satırları (computed property) BİLEREK hariç, TS karşılığı olmayan
  // türetilmiş alanlar (ör. `String get tamAd`) sahte uyumsuzluk üretmesin.
  const alanRegex = /^\s*final\s+[\w<>?,.\s]+?\s+(\w+)\s*(?:=[^;]+)?;/gm;

  for (const dosyaYolu of dosyalar) {
    const icerik = fs.readFileSync(dosyaYolu, 'utf8');
    let m;
    while ((m = sinifRegex.exec(icerik))) {
      const isim = m[1];
      const acilis = m.index + m[0].length - 1;
      const kapanis = eslesenKapaniAyracaBul(icerik, acilis);
      const govde = icerik.slice(acilis + 1, kapanis);
      const alanlar = sonuc.get(isim) ?? new Set();
      let fm;
      alanRegex.lastIndex = 0;
      while ((fm = alanRegex.exec(govde))) {
        alanlar.add(fm[1]);
      }
      sonuc.set(isim, alanlar);
    }
  }
  return sonuc;
}

function dartKarsiligiBul(tsIsim, dartSiniflar) {
  if (dartSiniflar.has(tsIsim)) return tsIsim;
  const sadelestirilmis = tsIsim.replace(/(Response|Request)$/, '');
  if (sadelestirilmis !== tsIsim && dartSiniflar.has(sadelestirilmis)) return sadelestirilmis;
  if (ELLE_ESLEME[tsIsim] && dartSiniflar.has(ELLE_ESLEME[tsIsim])) return ELLE_ESLEME[tsIsim];
  return null;
}

function calistir() {
  const tsArayuzler = tsArayuzleriniCikar();
  const dartSiniflar = dartSiniflariniCikar();

  let uyumsuzlukVar = false;
  let eslesenSayisi = 0;

  for (const [tsIsim, tsAlanlar] of tsArayuzler) {
    const dartIsim = dartKarsiligiBul(tsIsim, dartSiniflar);
    if (!dartIsim) continue; // Dart'ta kasıtlı olarak mirror edilmemiş olabilir
    eslesenSayisi++;

    const dartAlanlar = dartSiniflar.get(dartIsim);
    const eksikDart = [...tsAlanlar].filter((a) => !dartAlanlar.has(a));
    const fazlaDart = [...dartAlanlar].filter((a) => !tsAlanlar.has(a));

    if (eksikDart.length || fazlaDart.length) {
      uyumsuzlukVar = true;
      console.error(`\n[UYUMSUZ] ${tsIsim} (TS)  ↔  ${dartIsim} (Dart)`);
      if (eksikDart.length) console.error(`  TS'te var, Dart'ta YOK: ${eksikDart.join(', ')}`);
      if (fazlaDart.length) console.error(`  Dart'ta var, TS'te YOK: ${fazlaDart.join(', ')}`);
    }
  }

  if (uyumsuzlukVar) {
    console.error('\nÖzet: shared-types ile Dart aynası arasında alan uyumsuzluğu bulundu.');
    console.error('Düzelt: packages/shared-types/src/*.types.ts değiştiyse packages/app/lib altındaki');
    console.error('karşılığını (jsondan/jsonaDonustur dahil) aynı PR içinde güncelle.');
    process.exitCode = 1;
  } else {
    console.log(
      `Tip senkron kontrolü geçti — ${tsArayuzler.size} TS arayüzü tarandı, ${eslesenSayisi} tanesi Dart'ta eşleşti (kalanı kasıtlı olarak mirror edilmemiş).`,
    );
  }
}

calistir();
