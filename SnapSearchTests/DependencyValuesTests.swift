//
//  DependencyValuesTests.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/06
//  

@testable import SnapSearch
import Testing

// MARK: - テストデータ

enum FeatureFlagKey: DependencyKey {
    static let liveValue: Bool = false
}

struct UserConfig: Sendable, Equatable {
    var name: String
    var level: Int
}

enum UserConfigKey: DependencyKey {
    static let liveValue: UserConfig = .init(name: "live", level: 0)
}

extension DependencyValues {
    var featureEnabled: Bool {
        get { self[FeatureFlagKey.self] }
        set { self[FeatureFlagKey.self] = newValue }
    }
    var userConfig: UserConfig {
        get {self[UserConfigKey.self] }
        set { self[UserConfigKey.self] = newValue}
    }
}

struct FeatureConsumer {
    @Dependency(\.featureEnabled) var enabled: Bool
    func isOn() -> Bool { enabled }
}

struct ConfigConsumer {
    @Dependency(\.userConfig) var config: UserConfig
    func current() -> UserConfig { config }
}

// MARK: - テスト

@Suite
struct DependencyValuesTests {
    
    @Test
    func FeatureConsumerが_依存未設定の時_liveValueを返す() {
        // given: 依存未設定
        let consumer = FeatureConsumer()
        // when: 参照
        let v = consumer.isOn()
        // then: liveValue(false)
        #expect(v == false)
    }

    @Test
    func FeatureConsumerが_同期スコープ内の時_上書き値trueを返しスコープ外はfalseを返す() {
        // given: 外側はfalse
        #expect(FeatureConsumer().isOn() == false)

        // when: 同期スコープでtrueに上書き
        let inside = DependencyValues.withDependency {
            $0.featureEnabled = true
        } operation: {
            FeatureConsumer().isOn()
        }

        // then: 内=true 外=false
        #expect(inside == true)
        #expect(FeatureConsumer().isOn() == false)
    }

    @Test
    func 依存スコープが_ネストされた時_内側の値が優先される() {
        // given+when: 外= true → 内= false → 外に戻る
        let tuple = DependencyValues.withDependency {
            $0.featureEnabled = true
        } operation: {
            let outer = FeatureConsumer().isOn()
            let inner = DependencyValues.withDependency({ $0[FeatureFlagKey.self] = false }) {
                FeatureConsumer().isOn()
            }
            let outerAgain = FeatureConsumer().isOn()
            return (outer, inner, outerAgain)
        }

        // then
        #expect(tuple.0 == true)
        #expect(tuple.1 == false)
        #expect(tuple.2 == true)
        #expect(FeatureConsumer().isOn() == false)
    }

    @Test
    func 子Taskが_非同期スコープ内の時_上書き値を参照する() async {
        // given: 外側はfalse
        #expect(FeatureConsumer().isOn() == false)

        // when: 非同期スコープでtrueに上書きし子Taskで参照
        let (direct, child) = await DependencyValues.withDependency {
            $0.featureEnabled = true
        } operation: {
            let d = FeatureConsumer().isOn()
            let c = await Task { FeatureConsumer().isOn() }.value
            return (d, c)
        }

        // then: スコープ内と子Taskの両方でtrue
        #expect(direct == true)
        #expect(child == true)
        #expect(FeatureConsumer().isOn() == false)
    }

    @Test
    func 別キーが_上書きされた時_他のキーに影響しない() {
        // given: 両キーlive
        #expect(FeatureConsumer().isOn() == false)
        #expect(ConfigConsumer().current() == .init(name: "live", level: 0))

        // when: UserConfigのみ上書き
        let (cfgIn, flagIn) = DependencyValues.withDependency {
            $0.userConfig = .init(name: "custom", level: 2)
        } operation: {
            (ConfigConsumer().current(), FeatureConsumer().isOn())
        }

        // then: UserConfigだけ変化/FeatureFlagは不変
        #expect(cfgIn == .init(name: "custom", level: 2))
        #expect(flagIn == false)

        // スコープ外は元に戻る
        #expect(ConfigConsumer().current() == .init(name: "live", level: 0))
        #expect(FeatureConsumer().isOn() == false)
    }

    @Test
    func 同一タスクが_awaitをまたぐ時_上書き値を維持する() async {
        // given+when: 非同期スコープでtrueに上書きしawait境界を挟む
        let kept = await DependencyValues.withDependency {
            $0.featureEnabled = true
        } operation: {
            _ = await Task { () }.value  // 微小await
            return FeatureConsumer().isOn()
        }

        // then: 同一タスク内ではtrueを維持、外ではfalse
        #expect(kept == true)
        #expect(FeatureConsumer().isOn() == false)
    }
}
