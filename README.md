# triple-club-mileage-service

> [Coding assignment] 트리플여행자 클럽 마일리지 서비스

- [트리플 여행자 클럽 마일리지란?](#트리플-여행자-클럽-마일리지가-무엇인가요)
- [요구사항](#요구사항)
- [가정한 것](#가정한-것)
- [추가적으로 고민할 것](#추가적으로-고민할-것)
- [Pseudo code](pseudo/)
- [Schema DDL](schema.sql)
- [Project Structure](#Project-Structure)
- [API Spec](#API-Spec)

## 트리플 여행자 클럽 마일리지가 무엇인가요

- 트리플 사용자들 생생한 경험을 공유하며, 트리플의 생태계가 유지될 수 있습니다.
- 이를 활발히 지원하기 위한 트리플 여행자 클럽입니다.
- 쌓인 여행 포인트에 따라, 다양한 등급별 혜택이 있습니다.
- [branch - 트리플 여행자 클럽을 소개합니다.](https://brunch.co.kr/@triple/123)
- [트리플 여행자 클럽 FAQ](https://triple.guide/pages/mileage-faq.html)

## 요구사항

- 트리플 사용자들이 장소에 리뷰를 작성/수정/삭제할 때, 리뷰 서비스로부터 요청을 받아 포인트에 대한 처리를 하는 클럽 마일리지 서비스의 Pseudo code를 작성합니다.
  - 포인트의 적립 또는 회수
  - 한 사용자는 장소마다 리뷰를 1개만 작성할 수 있고, 리뷰는 수정 또는 삭제할 수 있습니다. 리뷰 작성 보상 점수는 아래와 같습니다.
    - 내용 점수
      - 1자 이상 텍스트 작성: 1점
      - 1장 이상 사진 첨부: 1점
    - 보너스 점수
      - 특정 장소에 첫 리뷰 작성: 1점
  - (개인적으로 추가) 포인트의 변경에 따른 레벨 변경
  - 전체/개인에 대한 포인트 변경 내역 관리/조회  
  
- 이 서비스를 다룰 수 있는 스키마를 설계합니다.
  - 테이블 DDL을 정의합니다. (MySQL 5.7 기준)
  - 인덱스를 정의합니다.

### 포인트 서비스의 리뷰 작성 이벤트 API
```json
POST /events

{
 "type": "REVIEW",
 "action": "ADD", /* "MOD", "DELETE" */
 "reviewId": "240a0658-dc5f-4878-9381-ebb7b2667772",
 "content": "좋아요!",
 "attachedPhotoIds": ["e4d1a64e-a531-46de-88d0-ff0ed70c0bb8", "afb0cef2-851d-4a50-bb07-9cc15cbdc332"],
 "userId": "3ede0ef2-92b7-4817-a5f3-0c575361f745",
 "placeId": "2e4baf1c-5acb-4efb-a1af-eddada31b00f"
}
```

## 가정한 것

- 리뷰의 작성 순서는 리뷰 서비스에서의 생성시점을 기준으로 합니다.
  - 리뷰 서비스가 이벤트 API를 전달받은 시점은 리뷰가 생성된 시점과 다를 수 있습니다.
  - HTTP congestion control 또는 네트워크 상황에 따릅니다.
  - 사용자가 실제로 리뷰를 작성한 시점 또한, 리뷰 서비스의 시점과 다를 수 있습니다.
  - 그러나 효율적인 서비스를 위해, 리뷰 서비스의 생성시점을 기준으로 합니다.
  - 리뷰 작성일시는 리뷰 서비스에서 이벤트 API로 전달된 UUID로 조회가능
- 여행자 클럽 포인트는 사용할 수 없습니다.
  - 따라서, 리뷰 삭제 또는 부적절한 행위 시 회수 가능합니다.  
- 포인트 서비스의 Endpoint는 외부에서 접근할 수 없습니다.
  - 리뷰 서비스 또는 사용자 서비스를 통해 접근합니다.
- 사용자에게 보여주는 포인트 트랜잭션의 메시지는 DeatilType과 Action을 조합하여, 클라이언트에서 제어합니다.
  - DB에서 관리할 만큼 자주 바뀌거나 케이스가 많을 때 테이블로 만들고, PointTransaction 테이블에 ForeignKey로 넣습니다. 

## 추가적으로 고민할 것

- 장소 이외의 여행 상품의 리뷰 지원
- 레벨업 혜택의 발송 일시 제공 여부
  - 기프티콘, 바우쳐 등은 API를 사용하지 않는한 일괄처리를 할 것으로 예상됨
  - 따라서, 주기적으로 일괄 발송 한다면 레벨업 시점에 따라 고객 안내를 함
  - 고객문의를 줄일 수 있어, 업무 효율화 가능
- 리뷰 작성 이벤트 API의 action을 HTTP header method로 대체
  - REST API에 더 적합한 방식으로 생각됨
  - Action enum에 대한 의존도를 줄일 수 있음

## Project Structure 
```bash
➜ tree triple-club-mileage-service -L 2 -C
triple-club-mileage-service
├── LICENSE
├── README.md                      --->  과제 설명
├── pseudo                         --->  pseduo code dir
│   ├── Class.pseudo               --->  class, enum
│   ├── EventController.pseudo     --->  리뷰 이벤트 API 컨트롤러
│   ├── PointTransactionController --->  포인트 트랜잭션 API 컨트롤러
│   ├── PointTransactionService    --->  포인트 트랜잭션 서비스 
│   └── ReviewEventService.pseudo  --->  리뷰 이벤트 서비스
└── schema.sql                     --->  DDL SQL 
```

## API Spec
| Action                              | API path           | Parameter                                          | Body                                                                                                                                                                                                                                                                                                                                       | Success Response                                                                                                                                                                                                                                                                                            | Fail Response                                                                                             |
| ----------------------------------- | ------------------ | -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| [이벤트] 이벤트에 따른 포인트 변경                | POST /events/      |                                                    | {"type": "REVIEW", "action": "ADD", /* "MOD", "DELETE" */"reviewId": "240a0658-dc5f-4878-9381-ebb7b2667772", "content": "좋아요!", "attachedPhotoIds": ["e4d1a64e-a531-46de-88d0-ff0ed70c0bb8", "afb0cef2-851d-4a50-bb07-9cc15cbdc332"], "userId": "3ede0ef2-92b7-4817-a5f3-0c575361f745", "placeId": "2e4baf1c-5acb-4efb-a1af-eddada31b00f"} | {"pointTrasactionIds": ["240a0658-240a0658-240a0658-240a0658", ...], "pointDiff": 3, point: 3}                                                                                                                                                                                                              | 400 {"error": "not suport event type: TEST"}                                                              |
| [포인트 트랜잭션] UUID로 조회                 | GET /points/{UUID} |                                                    |                                                                                                                                                                                                                                                                                                                                            | {"pointTransactionId": "240a0658-240a0658-240a0658-240a0658", "userId": "3ede0ef2-92b7-4817-a5f3-0c575361f745", "eventType": "REVIEW" /* "REVERVATION", "EXPERIENCE" \*/, "action": "ADD", /* "MOD", "DELETE" \*/, detailType: "REVIEW_TEXT" /* "REVIEW_PHOTO", "REVIEW_FIRST" \*/, point: 3, pointDiff: 1} | 404 {"error": "not exist point transaction with pointTransactionId: 240a0658-240a0658-240a0658-240a0658"} |
| [포인트 트랜잭션] User로 마지막 포인트 트랜잭션 조회    | GET /points/last   | ?userId=[UUID]                                     |                                                                                                                                                                                                                                                                                                                                            | 위와 동일                                                                                                                                                                                                                                                                                                       | 404 {"error": "not exist point transaction with user transaction: 240a0658-240a0658-240a0658-240a0658"}   |
| [포인트 트랜잭션] User로 포인트 트랜잭션 Paging 조회 | GET /points/       | ?userId=[UUID]{&pageNum=1&size=20 /* default 값 */} |                                                                                                                                                                                                                                                                                                                                            | {"total": 42, "pageNum": 1, "size": 20, "count": 20, "isLastPage": False, items: [ {/* 포인트 트랜잭션 조회 결과 */}, ... ] }                                                                                                                                                                                          |                                                                                                           |
| [포인트 트랜잭션] 전체 포인트 트랜잭션 Paging 조회    | GET /points/       | {&pageNum=1&size=20 /* default 값 */}               |                                                                                                                                                                                                                                                                                                                                            | 위와 동일                                                                                                                                                                                                                                                                                                       |                                                                                                           |