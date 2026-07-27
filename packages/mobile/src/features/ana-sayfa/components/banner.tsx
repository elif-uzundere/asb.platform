import { useEffect, useRef, useState } from 'react';
import {
  Dimensions,
  NativeScrollEvent,
  NativeSyntheticEvent,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';

const bannerlar = ['Banner 1', 'Banner 2', 'Banner 3'];

const { width } = Dimensions.get('window');

const bannerWidth = Math.min(width - 32, 700);

export function Banner() {
  const [aktifBanner, setAktifBanner] = useState(0);

  const scrollRef = useRef<ScrollView>(null);

  useEffect(() => {
    const timer = setInterval(() => {
      setAktifBanner((oncekiBanner) => {
        const sonrakiBanner = (oncekiBanner + 1) % bannerlar.length;

        scrollRef.current?.scrollTo({
          x: sonrakiBanner * bannerWidth,
          animated: true,
        });

        return sonrakiBanner;
      });
    }, 2000);

    return () => clearInterval(timer);
  }, []);

  function kaydirmaBitti(
    event: NativeSyntheticEvent<NativeScrollEvent>,
  ) {
    const yatayKonum = event.nativeEvent.contentOffset.x;

    const yeniBanner = Math.round(yatayKonum / bannerWidth);

    setAktifBanner(yeniBanner);
  }

  return (
    <View style={styles.wrapper}>
      <ScrollView
        ref={scrollRef}
        horizontal
        pagingEnabled
        showsHorizontalScrollIndicator={false}
        onMomentumScrollEnd={kaydirmaBitti}
        style={styles.scrollView}
      >
        {bannerlar.map((banner, index) => (
          <View
            key={index}
            style={[styles.bannerItem, { width: bannerWidth }]}
          >
            <Text style={styles.text}>{banner}</Text>
          </View>
        ))}
      </ScrollView>

      <View style={styles.dots}>
        {bannerlar.map((_, index) => (
          <View
            key={index}
            style={[
              styles.dot,
              index === aktifBanner && styles.activeDot,
            ]}
          />
        ))}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    width: '100%',
    maxWidth: 700,
    height: 100,
    alignSelf: 'center',
    marginTop: 8,
    marginBottom: 20,
    overflow: 'hidden',
    borderRadius: 16,
  },

  scrollView: {
    width: '100%',
  },

  bannerItem: {
    height: 100,
    backgroundColor: '#ffffff',
    justifyContent: 'center',
    alignItems: 'center',
  },

  text: {
    fontSize: 22,
    fontWeight: 'bold',
  },

  dots: {
    position: 'absolute',
    bottom: 10,
    alignSelf: 'center',
    flexDirection: 'row',
  },

  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#cccccc',
    marginHorizontal: 4,
  },

  activeDot: {
    width: 20,
    backgroundColor: '#0A4D8C',
  },
});