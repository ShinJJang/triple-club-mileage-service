CREATE DATABASE point DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
use point;

CREATE TABLE point_trasaction (
    id binary(16) NOT NULL COMMENT 'UUID 포인트 트랜잭션 ID',
    userId binary(16) NOT NULL COMMENT '사용자 UUID',
    eventType varchar(15) NOT NULL COMMENT '이벤트 종류: REVIEW, RESERVATION, EXPERIENCE',
    eventId binary(16) NOT NULL COMMENT '이벤트에 관련된 UUID ex) 리뷰 UUID',
    action varchar(10) NOT NULL COMMENT '이벤트의 action: ADD, MOD, DELETE',
    detailType varchar(20) NOT NULL COMMENT '포인트 변경 상세 종류: REVIEW_TEXT, REVIEW_PHOTO, REVIEW_FIRST',
    point int UNSIGNED NOT NULL COMMENT '트랜잭션 시점의 사용자의 포인트',
    pointDiff tinyint UNSIGNED NOT NULL COMMENT '트랜잭션으로 변경된 포인트',
    createdAt datetime NOT NULL DEFAULT NOW() COMMENT '생성일시',
    PRIMARY KEY(id),
    INDEX idx_userId (userId),
    INDEX idx_event (eventType, eventId),
    INDEX idx_createdAt (createdAt),

) ENGINE=InnoDB DEFAULT CHARSET=utf8