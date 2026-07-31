module.exports = {
  rootDir: '.',
  testRegex: '.*\\.spec\\.ts$',
  transform: {
    // TS151002: tsconfig'deki hybrid module (Node16) uyarısı — projeyi
    // etkilemiyor, sadece her testte tekrarlanan gürültü. Susturuldu.
    '^.+\\.(t|j)s$': ['ts-jest', { diagnostics: { ignoreCodes: [151002] } }],
  },
  moduleFileExtensions: ['js', 'json', 'ts'],
  passWithNoTests: true,
};
