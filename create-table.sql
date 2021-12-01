--
-- 프로그램(예: 마인크래프트, 메이플스토리)들이 저장될 테이블
--
CREATE TABLE 프로그램(
    프로그램이름 VARCHAR2(50) PRIMARY KEY,
    프로그램설명 VARCHAR2(200) NOT NULL,
    아이콘 VARCHAR2(200)
);

--
-- 운영체제(Windows, Mac OS, Linux, Free DOS)가 저장될 테이블
--
CREATE TABLE 운영체제(
    운영체제이름 VARCHAR2(30) PRIMARY KEY
);

--
-- 프로그램이 지원하는 운영체제(예: 메이플스토리 -> Windows)들이 저장될 테이블
--
CREATE TABLE 프로그램지원운영체제(
    프로그램이름 VARCHAR2(50) REFERENCES 프로그램(프로그램이름),
    운영체제이름 VARCHAR2(30) REFERENCES 운영체제(운영체제이름),
    
    CONSTRAINT PK_프로그램지원운영체제 PRIMARY KEY (프로그램이름, 운영체제이름)
);

--
-- CPU와 해당되는 벤치마크 점수가 저장되는 테이블
--
CREATE TABLE CPU(
    CPU이름 VARCHAR2(80) PRIMARY KEY,
    아키텍쳐 VARCHAR2(20) NOT NULL,
    브랜드 VARCHAR2(20) NOT NULL,
    벤치마크점수 NUMBER,
    벤치마크출처 VARCHAR2(50)
);

--
-- GPU와 해당되는 벤치마크 점수가 저장되는 테이블
--
CREATE TABLE GPU(
    GPU이름 VARCHAR2(80) PRIMARY KEY,
    브랜드 VARCHAR2(20) NOT NULL,
    벤치마크점수 NUMBER,
    벤치마크출처 VARCHAR2(50)
);

--
-- 프로그램에서 요구하는 사양을 항목별로 저장하는 테이블.
-- 예: 마인크래프트 권장사양: i5-4690, GTX 660, 4096
--
CREATE TABLE 프로그램사양(
    프로그램사양ID NUMBER PRIMARY KEY,
    프로그램이름 VARCHAR2(50) REFERENCES 프로그램(프로그램이름),
    세부사항 VARCHAR2(50) NOT NULL,
    CPU이름 VARCHAR2(30) REFERENCES CPU(CPU이름),
    GPU이름 VARCHAR2(30) REFERENCES GPU(GPU이름),
    RAM NUMBER
);

--
-- 다나와에서 판매되고 있는 노트북 제품
--
CREATE TABLE 제품정보(
    제품정보ID VARCHAR2(80) PRIMARY KEY,
    제품이름 VARCHAR2(200) NOT NULL,
    이미지 VARCHAR2(200),
    브랜드 VARCHAR2(50) NOT NULL,
    등록일 DATE,
    CPU이름 VARCHAR2(30) REFERENCES CPU(CPU이름),
    GPU이름 VARCHAR2(30) REFERENCES GPU(GPU이름),
    RAM NUMBER NOT NULL,
    운영체제이름 VARCHAR2(30) REFERENCES 운영체제(운영체제이름),
    화면크기 VARCHAR2(20),
    화면비율 VARCHAR2(20),
    해상도 VARCHAR2(20),
    무게 VARCHAR2(20)
);

--
-- 동일 제품에 여러 개의 옵션이 저장될 수 있음(SSD 256GB, SSD 1TB 등)
--
CREATE TABLE 제품옵션(
    제품ID VARCHAR2(80) PRIMARY KEY,
    제품정보ID VARCHAR2(80) REFERENCES 제품정보(제품정보ID),
    제품옵션이름 VARCHAR2(50) NOT NULL,
    가격 NUMBER
);

--
-- 제품 별로 구동 가능한 프로그램사양이 저장되는 테이블(트리거로 계산되어 저장될 예정)
--
CREATE TABLE 제품별가능한프로그램(
    제품정보ID REFERENCES 제품정보(제품정보ID),
    프로그램사양ID REFERENCES 프로그램사양(프로그램사양ID),
    
    CONSTRAINT PK_제품별가능한프로그램 PRIMARY KEY (제품정보ID, 프로그램사양ID)
);





--
-- 프로그램사양 ID의 값을 자동으로 증가시키기 위한 시퀀스
--
CREATE SEQUENCE SEQ_프로그램사양ID;

--
-- 프로그램사양 ID 값을 자동으로 설정하는 트리거
--
CREATE OR REPLACE TRIGGER T_프로그램사양ID
    BEFORE INSERT
    ON 프로그램사양
    FOR EACH ROW
BEGIN
    SELECT SEQ_프로그램사양ID.NEXTVAL INTO :NEW.프로그램사양ID FROM DUAL;
END;





--
-- 운영체제 이름을 정규화하는 함수.
-- 결과 값은 Windows, Mac OS, Linux, Free DOS 중 하나이며,
-- 대소문자가 잘못된 경우 고치는 역할을 수행하기도 한다.
--
CREATE OR REPLACE FUNCTION F_운영체제_정규화(V_운영체제 운영체제.운영체제이름%TYPE) RETURN 운영체제.운영체제이름%TYPE
AS
    V_LOWER운영체제 운영체제.운영체제이름%TYPE;
BEGIN
    V_LOWER운영체제 := TRIM(LOWER(V_운영체제));

    IF V_LOWER운영체제 = 'windows' THEN
        RETURN 'Windows';
    ELSIF V_LOWER운영체제 = 'mac os' OR V_LOWER운영체제 = 'macos' THEN
        RETURN 'Mac OS';
    ELSIF V_LOWER운영체제 = 'linux' THEN
        RETURN 'Linux';
    END IF;

    RETURN 'Free DOS';
END;

--
-- 운영체제 이름을 자동으로 정규화하는 트리거.
--
CREATE OR REPLACE TRIGGER T_운영체제_체크
    BEFORE INSERT OR UPDATE
    OF 운영체제이름 ON 운영체제
    FOR EACH ROW
BEGIN
    :NEW.운영체제이름 := F_운영체제_정규화(:NEW.운영체제이름);
END;





--
-- 아키텍쳐 이름에 제약을 거는 트리거.
-- x86, arm 값만 허용한다.
--
CREATE OR REPLACE TRIGGER T_CPU아키텍쳐_체크
    BEFORE INSERT OR UPDATE
    OF 아키텍쳐 ON CPU
    FOR EACH ROW
BEGIN
    IF :OLD.아키텍쳐 != 'x86' AND :OLD.아키텍쳐 != 'arm' THEN
        RAISE_APPLICATION_ERROR(-20000, '아키텍쳐는 x86 또는 arm 중 하나여야 합니다.');
    END IF;
END;





--
-- CPU 브랜드에 제약을 거는 트리거.
-- Intel, AMD, Apple 값만 허용한다.
--
CREATE OR REPLACE TRIGGER T_CPU브랜드_체크
    BEFORE INSERT OR UPDATE
    OF 브랜드 ON CPU
    FOR EACH ROW
BEGIN
    IF :OLD.브랜드 != 'Intel' AND :OLD.브랜드 != 'AMD' AND :OLD.브랜드 != 'Apple' THEN
        RAISE_APPLICATION_ERROR(-20000, '브랜드는 Intel, AMD 또는 Apple 중 하나여야 합니다.');
    END IF;
END;




--
-- GPU 브랜드에 제약을 거는 트리거.
-- Nvidia, AMD, Apple, Intel 값만 허용한다.
--
CREATE OR REPLACE TRIGGER T_GPU브랜드_체크
    BEFORE INSERT OR UPDATE
    OF 브랜드 ON GPU
    FOR EACH ROW
BEGIN
    IF :OLD.브랜드 != 'Nvidia' AND :OLD.브랜드 != 'AMD' AND :OLD.브랜드 != 'Apple' AND :OLD.브랜드 != 'Intel' THEN
        RAISE_APPLICATION_ERROR(-20000, '브랜드는 Nvidia, AMD, Apple 또는 Intel 중 하나여야 합니다.');
    END IF;
END;





--
-- 사양 판정을 수행하는 프로시저. ("최소, 권장" 또는 "최소" 또는 "" 과 같은 형태로 출력됨)
--
-- 예시)
-- SP_사양판정('메이플스토리', '4500U', 'GTX 1070', 4096, V_AVAILABLES)
--
-- V_AVAILABLES는 VARCHAR이며, OOO,XXX,TTTT 와 같은 형식으로 출력된다.
--
-- '최소사양,권장사양'
-- '권장사양'
-- ''
--
CREATE OR REPLACE PROCEDURE SP_사양판정(
    V_프로그램이름 IN 프로그램.프로그램이름%TYPE,
    V_CPU이름 IN CPU.CPU이름%TYPE,
    V_GPU이름 IN GPU.GPU이름%TYPE,
    V_RAM IN NUMBER,
    V_AVAILABLES OUT VARCHAR
)
AS
    V_CPU벤치마크점수 CPU.벤치마크점수%TYPE;
    V_GPU벤치마크점수 GPU.벤치마크점수%TYPE;
BEGIN
    V_AVAILABLES := '';

    SELECT 벤치마크점수 INTO V_CPU벤치마크점수 FROM CPU WHERE CPU이름 = V_CPU이름;
    SELECT 벤치마크점수 INTO V_GPU벤치마크점수 FROM GPU WHERE GPU이름 = V_GPU이름;

    -- 동적으로 커서를 생성해서 사용
    -- https://blog.kjslab.com/20
    FOR C IN (
        SELECT 세부사항, CPU.벤치마크점수 "CPU벤치마크점수", GPU.벤치마크점수 "GPU벤치마크점수", RAM
        FROM 프로그램사양
            INNER JOIN CPU ON 프로그램사양.CPU이름 = CPU.CPU이름
            INNER JOIN GPU ON 프로그램사양.GPU이름 = GPU.GPU이름
        WHERE 프로그램이름 = V_프로그램이름
    )
    LOOP
        -- CHECK SPEC (CPU, GPU, RAM)
        IF V_CPU벤치마크점수 >= C.CPU벤치마크점수
            AND V_GPU벤치마크점수 >= C.GPU벤치마크점수
            AND V_RAM >= C.RAM
        THEN
            -- CONCATENATE 세부사항
            V_AVAILABLES := V_AVAILABLES || C.세부사항 || ',';
        END IF;
    END LOOP;

    V_AVAILABLES := RTRIM(V_AVAILABLES, ',');
END;

--
-- SP_사양판정 테스트
--
DECLARE
    V_AVAILABLES VARCHAR(200);
BEGIN
    SP_사양판정('마인크래프트', '4500U', 'GTX 1070', 8192, V_AVAILABLES);
    
    DBMS_OUTPUT.PUT_LINE(V_AVAILABLES);
END;





--
-- CPU이름, GPU이름, RAM을 인자로 주면 V_RESULT 커서를 사용하여 프로그램의 적합 여부를 테이블로 반환하는 프로시저
--
-- 예시)
-- SP_적합프로그램목록('4500U', 'GTX 1070', 8192, V_CURSOR);
--
-- V_CURSOR를 사용하여 나온 결과값은 아래와 같다.
--
-- 메이플스토리 | 최소사양 | 1
-- 메이플스토리 | 권장사양 | 1
-- 마인크래프트 | 최소사양 | 1
-- 마인크래프트 | 권장사양 | 0
--
CREATE OR REPLACE PROCEDURE SP_적합프로그램목록(
    V_CPU이름 IN CPU.CPU이름%TYPE,
    V_GPU이름 IN GPU.GPU이름%TYPE,
    V_RAM IN NUMBER,
    V_RESULT OUT SYS_REFCURSOR
)
AS
    V_CPU벤치마크점수 CPU.벤치마크점수%TYPE;
    V_GPU벤치마크점수 GPU.벤치마크점수%TYPE;
BEGIN
    SELECT 벤치마크점수 INTO V_CPU벤치마크점수 FROM CPU WHERE CPU이름 = V_CPU이름;
    SELECT 벤치마크점수 INTO V_GPU벤치마크점수 FROM GPU WHERE GPU이름 = V_GPU이름;

    OPEN V_RESULT
    FOR
    SELECT 프로그램이름,
            세부사항,
            CASE WHEN (
                    CPU.벤치마크점수 <= V_CPU벤치마크점수
                    AND GPU.벤치마크점수 <= V_GPU벤치마크점수
                    AND RAM <= V_RAM
                ) THEN '적합'
                ELSE '부적합'
            END AS "적합"
    FROM 프로그램사양
        INNER JOIN CPU ON CPU.CPU이름 = 프로그램사양.CPU이름
        INNER JOIN GPU ON GPU.GPU이름 = 프로그램사양.GPU이름;
END;

--
-- SP_적합프로그램목록 테스트
--
DECLARE
    V_CURSOR SYS_REFCURSOR;
    V_프로그램이름 프로그램.프로그램이름%TYPE;
    V_세부사항 프로그램사양.세부사항%TYPE;
    V_적합 CHAR(1);
BEGIN
    SP_적합프로그램목록('4500U', 'GTX 1070', 8192, V_CURSOR);
    
    LOOP
        FETCH V_CURSOR INTO V_프로그램이름, V_세부사항, V_적합;
        EXIT WHEN V_CURSOR%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(V_프로그램이름 || '-' || V_세부사항 || ': ' || V_적합);
    END LOOP;
    CLOSE V_CURSOR;
END;





--
-- 프로그램사양ID 목록을 주면 해당 사양들에 모두 적합한 노트북 목록을 출력하는 프로시저
--
-- 입력은 '1,2,5,8' 과 같은 식으로, 하나의 문자열로 전달되어야 한다.
--
-- 출력은 cursor로 전달된다. 결과 값은 아래와 같다.
--
-- 15010340 | MSI GF시리즈 Sword GF76 A11UD 블랙 32GB램 | Intel Core i7-11800H | GeForce RTX 3050 Ti Laptop GPU | 32768
-- 15287000 | MSI 크리에이터 15 A11UE WIN10 64GB램 | Intel Core i7-11800H | GeForce RTX 3060 Ti | 65536
-- 15140024 | MSI GF시리즈 Sword GF76 A11SC 블랙 64GB램 | Intel Core i7-11800H | GeForce GTX 1650 | 65536
-- 15151349 | MSI GF시리즈 Sword GF76 A11SC 화이트 WIN10 64GB램 | Intel Core i7-11800H | GeForce GTX 1650 | 65536
-- 13782290 | Razer BLADE 15 Advanced 10Gen R3080 FHD | Intel Core i7-10875H | GeForce RTX 3080 | 32768
-- 14870228 | MSI GF시리즈 Sword GF66 A11SC-i5 화이트 32GB램 | Intel Core i5-11400H | GeForce GTX 1650 | 32768
-- 14816873 | 레노버 게이밍 3i 15IHU i7 3050 | Intel Core i7-11370H | GeForce RTX 3050 Ti Laptop GPU | 8192
--
CREATE OR REPLACE TYPE 프로그램사양ID목록 IS VARRAY(100) OF NUMBER NOT NULL;

--
-- 컴마(,)로 구분된 문자열을 NUMBER ARRAY로 변환하는 함수
--
-- 입력: 1,2,3,5,9
-- 출력: (1,2,3,5,9) (파싱됨)
--
CREATE OR REPLACE FUNCTION F_프로그램사양ID목록파싱(V_VALUES VARCHAR2) RETURN 프로그램사양ID목록 PIPELINED
AS
BEGIN
    -- 정규식을 사용하여 컴마(,) 기준으로 숫자들을 분리 및 PIPE
    FOR C IN (SELECT REGEXP_SUBSTR(V_VALUES, '[^,]+', 1, LEVEL) "VALUE"
                FROM DUAL
                CONNECT BY REGEXP_SUBSTR(V_VALUES, '[^,]+', 1, LEVEL) IS NOT NULL)
    LOOP
        PIPE ROW(TO_NUMBER(C.VALUE));
    END LOOP;
    RETURN;
END;

CREATE OR REPLACE PROCEDURE SP_다중프로그램적합노트북목록(
    V_프로그램사양ID목록RAW IN VARCHAR,
    V_CURSOR OUT SYS_REFCURSOR
)
AS
    V_CPU_REQUIRE NUMBER;
    V_GPU_REQUIRE NUMBER;
    V_RAM_REQUIRE NUMBER;
BEGIN
        -- 입력으로 주어진 프로그램사양ID 목록을 사용하여
        -- 이들을 모두 만족하는 CPU, GPU 최대 벤치마크 점수를 구한다.
        SELECT DISTINCT
            FIRST_VALUE(CPU.벤치마크점수) OVER (ORDER BY CPU.벤치마크점수 DESC) "CPU",
            FIRST_VALUE(GPU.벤치마크점수) OVER (ORDER BY GPU.벤치마크점수 DESC) "GPU",
            FIRST_VALUE(RAM) OVER (ORDER BY RAM DESC) "RAM"
        INTO
            V_CPU_REQUIRE, V_GPU_REQUIRE, V_RAM_REQUIRE
        FROM 프로그램사양
            INNER JOIN CPU ON CPU.CPU이름 = 프로그램사양.CPU이름
            INNER JOIN GPU ON GPU.GPU이름 = 프로그램사양.GPU이름
        WHERE 프로그램사양ID
            IN (SELECT * FROM TABLE(F_프로그램사양ID목록파싱(V_프로그램사양ID목록RAW)));
        
        -- 제품정보 데이터에서 CPU, GPU, RAM 요구사항을 만족하는
        -- 노트북 목록 검색, 이를 커서로 연결하여 사용자에게
        -- 테이블 형태로 반환
        OPEN V_CURSOR
        FOR
        SELECT 제품정보ID, 제품이름, 제품정보.CPU이름, 제품정보.GPU이름, RAM
        FROM 제품정보
            INNER JOIN CPU ON CPU.CPU이름 = 제품정보.CPU이름
            INNER JOIN GPU ON GPU.GPU이름 = 제품정보.GPU이름
        WHERE
            CPU.벤치마크점수 >= V_CPU_REQUIRE
            AND GPU.벤치마크점수 >= V_GPU_REQUIRE
            AND RAM >= V_RAM_REQUIRE;
END;


DECLARE
    V_CURSOR SYS_REFCURSOR;
    V_프로그램사양ID목록 VARCHAR(200);
    
    V_제품정보ID 제품정보.제품정보ID%TYPE;
    V_제품이름 제품정보.제품이름%TYPE;
    V_CPU이름 CPU.CPU이름%TYPE;
    V_GPU이름 GPU.GPU이름%TYPE;
    V_RAM 제품정보.RAM%TYPE;
BEGIN
    -- 64: 원신 권장사양
    -- 83: 던전앤파이터 최소사양
    -- 62: 리그오브레전드 최소사양
    -- 87: 마인크래프트 최소사양
    V_프로그램사양ID목록 := '65,83,62,87';

    SP_다중프로그램적합노트북목록(V_프로그램사양ID목록, V_CURSOR);
    
    LOOP
        FETCH V_CURSOR INTO V_제품정보ID, V_제품이름, V_CPU이름, V_GPU이름, V_RAM;
        EXIT WHEN V_CURSOR%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(V_제품정보ID || ' | ' || V_제품이름 || ' | ' || V_CPU이름 || ' | ' || V_GPU이름 || ' | ' || V_RAM);
    END LOOP;
    CLOSE V_CURSOR;
END;