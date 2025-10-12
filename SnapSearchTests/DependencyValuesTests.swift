//
//  DependencyValuesTests.swift
//  SnapSearch
//  
//  Created by Daiki Fujimori on 2025/10/06
//  

@testable import SnapSearch
import Testing

// MARK: - テストデータ

private struct TestDependencyKey: DependencyKey {
    static let liveValue: String = "live"
}

private struct NumberDependencyKey: DependencyKey {
    static let liveValue: Int = 42
}

private struct BoolDependencyKey: DependencyKey {
    static let liveValue: Bool = false
}

extension DependencyValues {
    fileprivate var testDependency: String {
        get { self[TestDependencyKey.self] }
        set { self[TestDependencyKey.self] = newValue }
    }
    
    fileprivate var numberDependency: Int {
        get { self[NumberDependencyKey.self] }
        set { self[NumberDependencyKey.self] = newValue }
    }
    
    fileprivate var boolDependency: Bool {
        get { self[BoolDependencyKey.self] }
        set { self[BoolDependencyKey.self] = newValue }
    }
}

// MARK: - Test Helpers

private struct TestService {
    @Dependency(\.testDependency) var testValue: String
    @Dependency(\.numberDependency) var numberValue: Int
    @Dependency(\.boolDependency) var boolValue: Bool
}

// MARK: - Tests

@Suite
struct DependencyValuesTests {
    
    // MARK: - デフォルト値のテスト
    
    @Test
    func カスタム値が設定されていない場合_依存性を取得した時_liveValueの文字列が返される() {
        // Given: デフォルト状態のDependencyValues
        let service = TestService()
        
        // When: 依存性の値を取得
        let result = service.testValue
        
        // Then: liveValueである"live"が返される
        #expect(result == "live")
    }
    
    @Test
    func カスタム値が設定されていない場合_数値型の依存性を取得した時_liveValueの42が返される() {
        // Given: デフォルト状態のDependencyValues
        let service = TestService()
        
        // When: 数値型の依存性を取得
        let result = service.numberValue
        
        // Then: liveValueである42が返される
        #expect(result == 42)
    }
    
    // MARK: - withDependency同期版のテスト
    
    @Test
    func withDependencyで値を上書きした場合_スコープ内で依存性を取得した時_上書きした文字列が返される() {
        // Given: "test"という値で依存性を上書き
        
        // When: withDependencyのスコープ内で依存性を取得
        let result = DependencyValues.withDependency {
            $0.testDependency = "test"
        } operation: {
            let service = TestService()
            return service.testValue
        }
        
        // Then: 上書きした"test"が返される
        #expect(result == "test")
    }
    
    @Test
    func withDependencyで値を上書きした場合_スコープ外で依存性を取得した時_liveValueの文字列が返される() {
        // Given: withDependencyで一時的に値を上書き
        _ = DependencyValues.withDependency {
            $0.testDependency = "temporary"
        } operation: {
            let service = TestService()
            return service.testValue
        }
        
        // When: スコープ外で依存性を取得
        let service = TestService()
        let result = service.testValue
        
        // Then: 元のliveValueである"live"が返される
        #expect(result == "live")
    }
    
    @Test
    func withDependencyをネストした場合_内側のスコープで依存性を取得した時_最も内側で設定した値が返される() {
        // Given: withDependencyを2重にネスト
        
        // When: 内側と外側で異なる値を設定し、内側で依存性を取得
        let result = DependencyValues.withDependency {
            $0.testDependency = "outer"
        } operation: {
            return DependencyValues.withDependency {
                $0.testDependency = "inner"
            } operation: {
                let service = TestService()
                return service.testValue
            }
        }
        
        // Then: 最も内側の"inner"が返される
        #expect(result == "inner")
    }
    
    @Test
    func withDependencyをネストした場合_外側のスコープで依存性を取得した時_外側で設定した値が返される() {
        // Given: withDependencyを2重にネスト
        
        // When: 内側のスコープを抜けた後、外側のスコープで依存性を取得
        let result = DependencyValues.withDependency {
            $0.testDependency = "outer"
        } operation: {
            _ = DependencyValues.withDependency {
                $0.testDependency = "inner"
            } operation: {
                let service = TestService()
                return service.testValue
            }
            let service = TestService()
            return service.testValue
        }
        
        // Then: 外側で設定した"outer"が返される
        #expect(result == "outer")
    }
    
    // MARK: - 複数の依存性のテスト
    
    @Test
    func 複数の依存性を設定した場合_それぞれの依存性を取得した時_設定した各値が返される() {
        // Given: 3つの異なる依存性に値を設定
        
        // When: withDependencyで複数の依存性を設定し、各値を取得
        let (stringResult, numberResult, boolResult) = DependencyValues.withDependency {
            $0.testDependency = "custom"
            $0.numberDependency = 100
            $0.boolDependency = true
        } operation: {
            let service = TestService()
            return (service.testValue, service.numberValue, service.boolValue)
        }
        
        // Then: それぞれ設定した値が返される
        #expect(stringResult == "custom")
        #expect(numberResult == 100)
        #expect(boolResult == true)
    }
    
    @Test
    func 一部の依存性のみ上書きした場合_上書きしていない依存性を取得した時_liveValueが返される() {
        // Given: testDependencyのみ上書き
        
        // When: 上書きした依存性と上書きしていない依存性を取得
        let (customResult, defaultResult) = DependencyValues.withDependency {
            $0.testDependency = "custom"
        } operation: {
            let service = TestService()
            return (service.testValue, service.numberValue)
        }
        
        // Then: 上書きした値は"custom"、上書きしていない値は42が返される
        #expect(customResult == "custom")
        #expect(defaultResult == 42)
    }
    
    // MARK: - withDependency非同期版のテスト
    
    @Test
    func 非同期withDependencyで値を上書きした場合_スコープ内で依存性を取得した時_上書きした文字列が返される() async {
        // Given: "async_test"という値で依存性を上書き
        
        // When: 非同期withDependencyのスコープ内で依存性を取得
        let result = await DependencyValues.withDependency {
            $0.testDependency = "async_test"
        } operation: {
            try? await Task.sleep(nanoseconds: 100_000)
            let service = TestService()
            return service.testValue
        }
        
        // Then: 上書きした"async_test"が返される
        #expect(result == "async_test")
    }
    
    @Test
    func 非同期withDependencyで値を上書きした場合_非同期処理後も依存性を取得した時_上書きした値が返される() async {
        // Given: "async_persistent"という値で依存性を上書き
        // When: 非同期処理を挟んでから依存性を取得
        let result = await DependencyValues.withDependency {
            $0.testDependency = "async_persistent"
        } operation: {
            try? await Task.sleep(nanoseconds: 1_000_000)
            let service = TestService()
            return service.testValue
        }
        
        // Then: 非同期処理後も"async_persistent"が返される
        #expect(result == "async_persistent")
    }
    
    @Test
    func 非同期withDependencyで値を上書きした場合_スコープ外で依存性を取得した時_liveValueが返される() async {
        // Given: withDependencyで一時的に値を上書き
        _ = await DependencyValues.withDependency {
            $0.testDependency = "temporary_async"
        } operation: {
            try? await Task.sleep(nanoseconds: 100_000)
            let service = TestService()
            return service.testValue
        }
        
        // When: スコープ外で依存性を取得
        let service = TestService()
        let result = service.testValue
        
        // Then: 元のliveValueである"live"が返される
        #expect(result == "live")
    }
    
    @Test
    func 非同期withDependencyをネストした場合_内側のスコープで依存性を取得した時_最も内側で設定した値が返される() async {
        // Given: 非同期withDependencyを2重にネスト
        
        // When: 内側と外側で異なる値を設定し、内側で依存性を取得
        let result = await DependencyValues.withDependency {
            $0.testDependency = "async_outer"
        } operation: {
            try? await Task.sleep(nanoseconds: 100_000)
            return await DependencyValues.withDependency {
                $0.testDependency = "async_inner"
            } operation: {
                try? await Task.sleep(nanoseconds: 100_000)
                let service = TestService()
                return service.testValue
            }
        }
        
        // Then: 最も内側の"async_inner"が返される
        #expect(result == "async_inner")
    }
    
    @Test
    func 非同期withDependencyをネストした場合_外側のスコープで依存性を取得した時_外側で設定した値が返される() async {
        // Given: 非同期withDependencyを2重にネスト
        
        // When: 内側のスコープを抜けた後、外側のスコープで依存性を取得
        let result = await DependencyValues.withDependency {
            $0.testDependency = "async_outer"
        } operation: {
            try? await Task.sleep(nanoseconds: 100_000)
            _ = await DependencyValues.withDependency {
                $0.testDependency = "async_inner"
            } operation: {
                try? await Task.sleep(nanoseconds: 100_000)
                let service = TestService()
                return service.testValue
            }
            let service = TestService()
            return service.testValue
        }
        
        // Then: 外側で設定した"async_outer"が返される
        #expect(result == "async_outer")
    }
    
    @Test
    func 非同期withDependencyをネストし異なる依存性を設定した場合_内側で両方の依存性を取得した時_それぞれ設定した値が返される() async {
        // Given: 外側でtestDependency、内側でnumberDependencyを設定
        
        // When: ネストしたスコープで両方の依存性を取得
        let result = await DependencyValues.withDependency {
            $0.testDependency = "async_outer_value"
        } operation: {
            try? await Task.sleep(nanoseconds: 100_000)
            return await DependencyValues.withDependency {
                $0.numberDependency = 777
            } operation: {
                try? await Task.sleep(nanoseconds: 100_000)
                let service = TestService()
                return (service.testValue, service.numberValue)
            }
        }
        
        // Then: 外側で設定した"async_outer_value"と内側で設定した777が返される
        #expect(result.0 == "async_outer_value")
        #expect(result.1 == 777)
    }
    
    // MARK: - @Dependencyプロパティラッパーのテスト
    
    @Test
    func Dependencyプロパティラッパーを使用した場合_デフォルト状態で値を取得した時_liveValueが返される() {
        // Given: Dependencyプロパティラッパーを持つ構造体
        let service = TestService()
        
        // When: デフォルト状態で値を取得
        // Then: 各liveValueが返される
        #expect(service.testValue == "live")
        #expect(service.numberValue == 42)
    }
    
    @Test
    func Dependencyプロパティラッパーを使用した場合_withDependencyスコープ内で値を取得した時_上書きした値が返される() {
        // Given: Dependencyプロパティラッパーを持つ構造体
        
        // When: withDependencyで値を上書きした状態でインスタンスを作成
        let result = DependencyValues.withDependency {
            $0.testDependency = "injected"
        } operation: {
            let service = TestService()
            return service.testValue
        }
        
        // Then: 上書きした"injected"が返される
        #expect(result == "injected")
    }
    
    @Test
    func Dependencyプロパティラッパーを複数持つ構造体で_一部の依存性のみ上書きした場合_上書きした依存性は設定値を返し上書きしていない依存性はliveValueを返す() {
        // Given: 複数のDependencyプロパティラッパーを持つ構造体
        
        // When: testDependencyのみ上書き
        let result = DependencyValues.withDependency {
            $0.testDependency = "only_string_changed"
        } operation: {
            let service = TestService()
            return (service.testValue, service.numberValue, service.boolValue)
        }
        
        // Then: 上書きした値は"only_string_changed"、上書きしていない値は42とfalseが返される
        #expect(result.0 == "only_string_changed")
        #expect(result.1 == 42)
        #expect(result.2 == false)
    }
    
    // MARK: - エッジケースのテスト
    
    @Test
    func withDependencyをネストし異なる依存性を設定した場合_内側で両方の依存性を取得した時_それぞれ設定した値が返される() {
        // Given: 外側でtestDependency、内側でnumberDependencyを設定
        
        // When: ネストしたスコープで両方の依存性を取得
        let result = DependencyValues.withDependency {
            $0.testDependency = "outer_value"
        } operation: {
            DependencyValues.withDependency {
                $0.numberDependency = 999
            } operation: {
                let service = TestService()
                return (service.testValue, service.numberValue)
            }
        }
        
        // Then: 外側で設定した"outer_value"と内側で設定した999が返される
        #expect(result.0 == "outer_value")
        #expect(result.1 == 999)
    }
}
