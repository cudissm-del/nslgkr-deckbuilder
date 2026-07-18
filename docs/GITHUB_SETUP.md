# GitHub 연동 + 프로젝트 지식 동기화 + 사이트 배포 가이드

목표 3가지:
1. `deckbuilder` 폴더를 GitHub 저장소로 올리기
2. 그 저장소를 Claude.ai 프로젝트에 **지식 소스로 연결(sync)** → 세션이 바뀌어도 Claude가 참조
3. 같은 저장소로 **GitHub Pages** 정적 사이트 배포

---

## 0단계 — 남은 `.git` 폴더 삭제 (한 번만)
Claude가 만들다 만 불완전한 `.git` 폴더가 있어요. 파일 탐색기에서 `E:\NSLGKR\deckbuilder` 안의 **`.git` 폴더를 삭제**하세요. (숨김 폴더면 보기 > 숨긴 항목 체크)

## 1단계 — GitHub에 빈 저장소 만들기
1. https://github.com/new 접속
2. Repository name: `nslgkr-deckbuilder` (원하는 이름)
3. Public/Private 선택 (Pages 무료는 Public 권장)
4. README/.gitignore/license **추가하지 말고** "Create repository"
5. 만들어진 저장소 주소 복사 (예: `https://github.com/<사용자명>/nslgkr-deckbuilder.git`)

## 2단계 — 내 PC에서 올리기 (Git Bash)
`E:\NSLGKR\deckbuilder` 폴더에서 우클릭 → **Git Bash Here** → 아래 순서로:

```bash
git init
git add -A
git commit -m "초기 커밋: 천하결전 덱빌더 데이터·문서"
git branch -M main
git remote add origin https://github.com/<사용자명>/nslgkr-deckbuilder.git
git push -u origin main
```

- 처음 push 시 브라우저로 GitHub 로그인 창이 뜨면 로그인(자격 증명 관리자가 저장).
- 용량 큰 `captures/videos`·`captures/frames`는 `.gitignore`로 자동 제외됨.

## 3단계 — Claude.ai 프로젝트에 저장소 연결 (지식 동기화)
1. Claude.ai에서 **"삼국지 천하결전" 프로젝트** 열기
2. 프로젝트 지식/설정에서 **소스 추가 → GitHub 저장소 연결**
3. `nslgkr-deckbuilder` 선택 (필요 시 GitHub 계정 인증)
→ 이후 세션에서 Claude가 이 저장소의 `PROJECT.md`·`data/*.json`을 지식으로 읽습니다. 데이터가 갱신되면 재동기화만 하면 최신 지식 반영.

## 4단계 — GitHub Pages로 사이트 배포 (사이트 완성 후)
1. 저장소 → Settings → Pages
2. Source: `Deploy from a branch` → Branch: `main` / 폴더 `/ (root)` 또는 `/docs`
3. 저장 후 몇 분 뒤 `https://<사용자명>.github.io/nslgkr-deckbuilder/` 에서 사이트 열림

> 사이트(HTML/JS)는 같은 저장소의 `data/*.json`을 fetch해서 덱빌더 UI를 그림. 데이터·사이트가 항상 한 저장소에서 일치.

---

## 앞으로의 흐름
- 데이터 추가/수정 → 커밋 & push → (프로젝트 재동기화) → Claude 지식 최신화 + 사이트 자동 갱신
- Claude가 데이터 파일을 수정해주면, 김정식님이 push만 하면 반영
