# 인천 블록체인 실습

## 설치 및 환경설정

### Bun 설치 방법

Bun을 설치하는 방법은 운영체제에 따라 다릅니다. 아래는 주요 운영체제별 설치 방법입니다.

**Linux & macOS**

```sh
curl -fsSL https://bun.sh/install | bash
```

**Windows**

```sh
powershell -c "irm bun.sh/install.ps1 | iex"
```

**설치 확인**

Bun이 올바르게 설치되었는지 확인하려면 터미널이나 명령 프롬프트를 열고 다음 명령어를 실행합니다:

```sh
bun --version
```

### Foundry 설치 및 확인

**macOS**
설치
```
$ curl -L https://foundry.paradigm.xyz | bash
foundryup
```

**Windows**
```
$ curl -L https://foundry.paradigm.xyz | bash
source /c/Users/username/.bashrc
foundryup
```

설치 확인
```
$ forge --version 
```

### 프로젝트 클론 및 의존성 설치

**프로젝트 클론**

```sh
mkdir incheon # incheon 폴더 생성
cd incheon # incheon 폴더로 이동
git clone https://github.com/madiha-right/flashloan.git # flashloan 레포지토리 클론
cd flashloan # flashloan 폴더로 이동
```

**의존성 설치**

```sh
bun install # 의존성 설치
```

## 명령어 목록

가장 자주 필요한 명령어 목록입니다.

### Build

컨트랙트를 빌드합니다:

```sh
$ forge build
```

### Clean

빌드 아티팩트 및 캐시 디렉토리를 삭제합니다:

```sh
$ forge clean
```

### Compile

컨트랙트를 컴파일합니다:

```sh
$ forge build
```

### Coverage

테스트 커버리지 보고서를 생성합니다:

```sh
$ forge coverage
```

### Deploy

Anvil에 배포합니다:

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url http://localhost:8545
```

이 스크립트를 실행하려면 MNEMONIC 환경 변수가 유효한 [BIP39 mnemonic](https://iancoleman.io/bip39/) 니모닉으로 설정되어
있어야 합니다.

테스트넷 또는 메인넷에 배포하는 방법에 대한 자세한 내용은
[Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting.html) 튜토리얼을 참조하세요.

### Format

컨트랙트를 포맷합니다:

```sh
$ forge fmt
```

### Gas Usage

가스 보고서를 생성합니다:

```sh
$ forge test --gas-report
```

### Lint

컨트랙트를 린트합니다:

```sh
$ bun run lint
```

### Test

테스트를 실행합니다:

```sh
$ forge test
```

테스트 커버리지를 생성하고 결과를 터미널에 출력합니다:

```sh
$ bun run test:coverage
```

lcov 보고서로 테스트 커버리지를 생성합니다 (브라우저에서 ./coverage/index.html 파일을 열어야 합니다. 경로를 복사하여
브라우저에 붙여넣기 하면 됩니다):

```sh
$ bun run test:coverage:report
```

## ⚡️ FlashLoan으로 포지션 열기 ⚡️

### 0. Setting

a. [Alchemy](https://www.alchemy.com/)로 이동해서 회원가입을 마친 후, ethereum mainnet API key를 발급 받습니다.

b. `foundry.toml` 파일을 열고 `[rpc_endpoints]` 섹션으로 이동합니다.

c. `mainnet` URL에 적혀 있는 `{IDWMMIb4whIZrlMz0nDvjbwJNQ2CLc4L}` 값을 "a"에서 발급한 API key로 대체합니다.

### 1. Compile

컨트랙트를 컴파일합니다:

```sh
$ forge compile
```

### 2. Fork

Mainnet의 환경과 상태를 Anvil 로컬 네트워크로 포크합니다:

```sh
$ anvil --fork-url mainnet
```

### 3. Deploy

새로운 터미널 창을 추가로 열고, Anvil에 컨트렉트를 배포합니다:

```sh
$ forge script script/Deploy.s.sol --broadcast --fork-url localhost
```

a. `OpenPosition.s.sol`로 이동합니다.

b. 출력값으로 나온 contract address를 `myContract` 변수의 value 값으로 저장합니다.

c. 예시: `address myContract = 0x9bE634797af98cB560DB23260b5f7C6e98AcCAcf;`

### 4. Impersonate user and transfer USDC

a. 메인넷에서 USDC를 가지고 있는 유저를 로컬 네트워크에서 가장합니다.

```sh
$ cast rpc anvil_impersonateAccount 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa
```

b. 담보로 사용할 USDC의 베이스 수량을 홀딩하는 상태를 만들기 위해 1000 USDC를 테스트 계정에 전송합니다. FlashLoan
수수료를 위해 1000 USDC를 전송합니다.

```sh
$ cast send 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
--from 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa \
  "transfer(address,uint256)(bool)" \
  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
  1000000000 \
  --unlocked \
	--gas-limit 500000
```

c. 쉬운 진행을 위해 Flash Leverage 과정에서 USDC <> DAI 스왑 과정을 생략합니다. 따라서 FlashLoan 상환을 위해 9000 USDC와
FlashLoan 수수료 2 USDC를 `MyContract.sol`에 전송합니다. 아래 커멘드에서 4번째 line의 0xblahblah 주소의 값을
`OpenPosition.s.sol`의 `myContract` 값과 동일하게 변경해줍니다.

```sh
$ cast send 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
--from 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa \
  "transfer(address,uint256)(bool)" \
  0x9bE634797af98cB560DB23260b5f7C6e98AcCAcf \
  9002000000 \
  --unlocked \
	--gas-limit 500000
```

### 5. Open a position

FlashLoan을 사용하여 레버리지된 DAI (대출) <> USDC (담보) 포지션을 생성합니다.

```sh
$ forge script script/OpenPosition.s.sol --broadcast --fork-url localhost -vvv
```

## 첨부링크

[노션 강의 자료](https://madiha-right.notion.site/2b5dddfd37ed4bbeb6d1db02cc3414a7?pvs=4)

## License

This project is licensed under MIT.
