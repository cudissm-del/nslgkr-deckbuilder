# 천하결전 덱빌더 — 데이터 스키마 (v0.1)

덱빌더 프론트엔드가 그대로 읽어들일 **데이터 계약**. 도감 캡처로 채운다.
모든 파일은 `data/*.json`. 아이디는 문자열, 수치는 숫자, 미확인 값은 `null`.

원칙
- **단일 진실원(single source of truth)**: 화면에서 확인된 값만 넣고, 추정값은 `"_estimated": true` 플래그.
- **명칭 = 한글(게임 표기) + 내부ID**: 나중에 번들 추출로 ID 매핑 가능하도록 `id` 병기.
- 상성·계수 같은 전투 공식 파라미터는 `combat.json`에 별도 분리.

---

## 1. `arms.json` — 병종 & 상성
```jsonc
{
  "arms": [
    { "id": "infantry", "name": "보병", "desc": "" },
    { "id": "archer",   "name": "궁병", "desc": "" },
    { "id": "cavalry",  "name": "기병", "desc": "" }
    // 공성/수군 등 추가 병종 발견 시 확장
  ],
  // 상성 배수: attacker → defender 곱연산 피해 보정
  "counter": {
    "infantry": { "archer": 1.0, "cavalry": null, "infantry": 1.0 },
    "archer":   { "cavalry": null, "infantry": null, "archer": 1.0 },
    "cavalry":  { "infantry": null, "archer": null, "cavalry": 1.0 }
  },
  // 확인된 순환: 보병 > 궁병 > 기병 > 보병 (배수는 캡처로 확정)
  "advancement": []  // 병종 승급 단계(해금/스탯보정)
}
```

## 2. `heroes.json` — 장수
```jsonc
{
  "heroes": [
    {
      "id": "cao_cao",
      "name": "조조",
      "faction": "위",                 // 위/촉/오/군/한 등
      "rarity": null,                   // 등급(SSR 등)
      "cost": null,                     // 편성 코스트(있으면)
      "stats": {                        // 만렙/등장 기준. 어느 기준인지 basisLevel에 기록
        "basisLevel": 50,
        "attack": null,   "武力": null, // 무력
        "intel": null,    "智力": null, // 지력
        "command": null,  "統率": null, // 통솔
        "speed": null,    "速度": null, // 속도
        "politics": null                // 정치(내정용, 선택)
      },
      "growth": {},                     // 레벨당 성장치(있으면)
      "armsAptitude": {                 // 병종 적성 등급 (S/A/B/C...)
        "infantry": null, "archer": null, "cavalry": null
      },
      "innateTactic": "tactic_id",      // 고유 전법 id
      "job": null,                      // 진군/신행/천공/기좌/청낭/병참 (플레이어 직업과 연동되면)
      "obtain": null,                   // 획득처
      "_source": "capture:도감/장수/조조"
    }
  ]
}
```

## 3. `tactics.json` — 전법 (덱 핵심)
```jsonc
{
  "tactics": [
    {
      "id": "t_wenwu_gyeombi",
      "name": "문무겸비",
      "type": null,          // 지휘/주동/돌격/추격/피동/병종/진법/내정
      "quality": null,       // 등급(S/A/B...)
      "trigger": {
        "kind": null,        // passive | active | on_attack | counter ...
        "rate": null,        // 발동 확률 %
        "cooldownTurns": null
      },
      "target": null,        // 아군 전체 / 적 단일 / 적 그룹 / 자신 ...
      "effect": "",          // 화면 설명 원문
      "coeff": {             // 레벨별 계수 (Lv1..Lv10)
        "stat": null,        // 무력/지력 기반 여부
        "levels": []         // [{lvl:1, value:..}, ...]
      },
      "arms": null,          // 특정 병종 전용이면 병종 id
      "source": null,        // 전수(계승) 장수 / 고유
      "innateOf": null,      // 이 전법이 고유인 장수 id
      "_source": "capture:도감/전법/문무겸비"
    }
  ]
}
```

## 4. `books.json` — 병서 (패시브 특성 트리)
```jsonc
{
  "books": [
    {
      "id": "b_offense",
      "name": "",            // 병서 페이지/계열명
      "tree": null,          // 공격/방어/기동/응변 등 계열
      "nodes": [
        {
          "id": "b_offense_n1",
          "name": "",
          "effect": "",      // 상시 보정 설명
          "cost": null,      // 소요 포인트
          "requires": []     // 선행 노드 id
        }
      ],
      "_source": "capture:도감/병서/…"
    }
  ]
}
```

## 5. `equipment.json` — 장비
```jsonc
{
  "equipment": [
    {
      "id": "e_baengniuiseong",
      "name": "백리의성",       // 스크린샷에서 관측된 아이템/전법 명칭 예시
      "slot": null,           // 무기/방어구/보조 등 슬롯
      "quality": null,
      "stats": { "attack": null, "intel": null, "command": null, "speed": null },
      "bonus": "",            // 부가 효과/전법 효과
      "enhance": null,        // 강화·제련 성장 규칙
      "_source": "capture:도감/장비/…"
    }
  ]
}
```

## 6. `combat.json` — 전투 공식 파라미터 (역산으로 채움)
```jsonc
{
  "maxTroopsPerHero": 10000,   // 스크린샷 관측: 장수당 10,000, 부대 3인=30,000
  "heroesPerTeam": 3,
  "rounds": null,              // 전투 총 라운드 수
  "damageModel": {             // 전투 보고서 역산으로 채움
    "note": "damage = f(stat, armsCounter, tacticCoeff, ...) — 캡처·역산 필요",
    "armsCounterApplies": true
  }
}
```

## 7. `decks.json` — 사용자 덱(빌더 출력)
```jsonc
{
  "decks": [
    {
      "id": "deck_wei_control",
      "name": "위 지력 컨트롤",
      "team": [
        { "heroId": "cao_cao", "arms": "infantry", "tactics": ["t_..","t_.."], "bookId": "b_offense", "equipment": ["e_.."] }
      ],
      "notes": ""
    }
  ]
}
```

---

## 캡처 우선순위
1. **병종 상성 배수**(arms.json) — 전투의 뼈대. 도감/전투백과에서 수치 확인.
2. **보유·주력 장수 스탯 + 병종적성**(heroes.json).
3. **주력 전법 계수/발동률**(tactics.json) — 덱 성능 1순위 변수.
4. 병서 트리(books.json), 장비 스탯(equipment.json).
5. 전투 보고서 여러 건 → combat.json 공식 역산.
