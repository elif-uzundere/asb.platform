// Yardım ve Destek'teki statik bilgi sayfalarının içeriği. Backend gerektiren
// bir şey değil (sabit metin), bu yüzden framework'ten bağımsız bir domain
// sabiti olarak burada duruyor — ekran sadece anahtarla arayıp gösteriyor.

class DestekIcerigi {
  const DestekIcerigi({required this.baslik, required this.paragraflar});

  final String baslik;
  final List<String> paragraflar;
}

const Map<String, DestekIcerigi> destekIcerikleri = {
  'guvenlik': DestekIcerigi(
    baslik: 'Güvenlik',
    paragraflar: [
      'Şifreniz sunucuda asla düz metin olarak saklanmaz — geri döndürülemez '
          'şekilde hash\'lenir. Girişten sonra cihazınızda tutulan oturum '
          'bilgisi, işletim sisteminin güvenli depolama alanında saklanır.',
      'Şifrenizi veya e-postanızı değiştirmek için önce mevcut şifrenizle '
          'kimliğinizi doğrulamanız istenir — bu, hesabınızın sizden başka '
          'biri tarafından değiştirilmesini engeller.',
      'Şüpheli bir durum fark ederseniz (örneğin tanımadığınız bir giriş '
          'bildirimi), Destek Talebi oluşturarak bize ulaşabilirsiniz.',
    ],
  ),
  'sik-sorular': DestekIcerigi(
    baslik: 'Sık Sorular',
    paragraflar: [
      'Şifremi unuttum, ne yapmalıyım? Giriş ekranındaki "Şifremi Unuttum" '
          'linkine tıklayıp e-posta adresinizi girin; size bir sıfırlama '
          'linki gönderilir. Link 15 dakika geçerlidir.',
      'Hesabımı nasıl silebilirim? Şu an için hesap silme işlemi Destek '
          'Talebi üzerinden bize iletilmelidir, ekibimiz sizinle iletişime '
          'geçer.',
      'Firma hesabım neden onay bekliyor? Bölgedeki firmalar, bölge '
          'yönetimi tarafından incelenip onaylandıktan sonra platformda '
          'görünür hale gelir. Bu süreç genellikle birkaç iş günü sürer.',
    ],
  ),
  'giris-hesap': DestekIcerigi(
    baslik: 'Giriş ve hesap sorunları',
    paragraflar: [
      'Giriş yapamıyorsanız önce e-posta ve şifrenizi kontrol edin — '
          'güvenlik nedeniyle hangi alanın hatalı olduğu ayrıca belirtilmez.',
      '"Beni Hatırla" seçeneğini işaretlerseniz oturumunuz 30 gün, '
          'işaretlemezseniz 1 gün açık kalır.',
      'Profil bilgilerinizi (ad, soyad, telefon) Profil > Bilgilerim > '
          'Bilgilerimi Düzenle üzerinden güncelleyebilirsiniz. E-posta ve '
          'şifre değişiklikleri, güvenlik nedeniyle kendi ayrı ekranlarında '
          've mevcut şifrenizi yeniden girerek yapılır.',
    ],
  ),
  'basvuru-ilan': DestekIcerigi(
    baslik: 'Başvuru ve ilan işlemleri',
    paragraflar: [
      'İş ilanları ve başvuru takibi özellikleri platforma yakında '
          'ekleniyor. Bu bölüm hazır olduğunda burada güncel bilgi '
          'bulacaksınız.',
    ],
  ),
  'bildirim-teknik': DestekIcerigi(
    baslik: 'Bildirim ve teknik sorunlar',
    paragraflar: [
      'Uygulamada beklenmedik bir hata mesajı görürseniz, önce uygulamayı '
          'kapatıp yeniden açmayı deneyin. Sorun devam ederse Destek Talebi '
          'oluşturup hata mesajının tam metnini bize iletmeniz çözümü '
          'hızlandırır.',
      'Bildirim tercihleri (push notification) özelliği platformun '
          'ilerleyen bir aşamasında eklenecek.',
    ],
  ),
  'gizlilik': DestekIcerigi(
    baslik: 'Gizlilik Politikası',
    paragraflar: [
      'Hesabınızı oluştururken bize sağladığınız bilgiler (ad, soyad, '
          'e-posta, telefon) yalnızca platform hizmetlerini sunmak amacıyla '
          'kullanılır ve üçüncü taraflarla pazarlama amacıyla paylaşılmaz.',
      'Şifreniz geri döndürülemez şekilde hash\'lenerek saklanır, hiçbir '
          'çalışanımız şifrenizi düz metin olarak göremez.',
      'Kişisel verilerinizin işlenmesine ilişkin haklarınız (erişim, '
          'düzeltme, silme talebi) için Destek Talebi oluşturarak veya '
          'Yardım ve Destek > İletişim bilgilerinden bize ulaşabilirsiniz.',
    ],
  ),
};
