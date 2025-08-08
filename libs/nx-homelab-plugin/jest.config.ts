/* eslint-disable */
export default {
    displayName: 'nx-homelab-plugin',
    preset: '../../jest.preset.js',
    testEnvironment: 'node',
    transform: {
        '^.+\\.[tj]s$': ['ts-jest', { tsconfig: '<rootDir>/tsconfig.spec.json' }],
    },
    moduleFileExtensions: ['ts', 'js', 'html'],
    coverageDirectory: '../../coverage/libs/nx-homelab-plugin',
    collectCoverageFrom: [
        '<rootDir>/generators/**/*.ts',
        '!<rootDir>/**/schema.ts',
    ],
    coverageReporters: ['text', 'lcov'],
};
