CREATE TABLE 프로그램(
    프로그램이름 CHAR(50) PRIMARY KEY,
    프로그램설명 VARCHAR(200) NOT NULL,
    아이콘 VARCHAR(200)
);

CREATE TABLE 프로그램지원운영체제(
    프로그램이름 CHAR(50) REFERENCES 프로그램(프로그램이름),
    운영체제 CHAR(30),
    
    CONSTRAINT PK_프로그램지원운영체제 PRIMARY KEY (프로그램이름, 운영체제)
);

CREATE TABLE CPU(
    CPU이름 CHAR(30) PRIMARY KEY,
    아키텍쳐 CHAR(20) NOT NULL,
    브랜드 CHAR(20) NOT NULL,
    벤치마크점수 NUMBER,
    벤치마크출처 CHAR(50)
);

CREATE TABLE GPU(
    GPU이름 CHAR(30) PRIMARY KEY,
    브랜드 CHAR(20) NOT NULL,
    벤치마크점수 NUMBER,
    벤치마크출처 CHAR(50)
);

CREATE TABLE 프로그램사양(
    프로그램사양ID NUMBER PRIMARY KEY,
    프로그램이름 CHAR(50) REFERENCES 프로그램(프로그램이름),
    세부사항 CHAR(50) NOT NULL,
    CPU이름 CHAR(30) REFERENCES CPU(CPU이름),
    GPU이름 CHAR(30) REFERENCES GPU(GPU이름),
    RAM NUMBER
);

CREATE TABLE 제품정보(
    제품정보ID CHAR(80) PRIMARY KEY,
    제품이름 CHAR(200) NOT NULL,
    이미지 VARCHAR(200),
    브랜드 CHAR(50) NOT NULL,
    등록일 DATE,
    CPU이름 CHAR(30) REFERENCES CPU(CPU이름),
    GPU이름 CHAR(30) REFERENCES GPU(GPU이름),
    RAM NUMBER,
    운영체제 CHAR(30),
    화면크기 CHAR(20),
    화면비율 CHAR(20),
    해상도 CHAR(20),
    무게 CHAR(20)
);

CREATE TABLE 제품옵션(
    제품ID CHAR(80) PRIMARY KEY,
    제품정보ID CHAR(80) REFERENCES 제품정보(제품정보ID),
    제품옵션이름 CHAR(50) NOT NULL,
    가격 NUMBER
);

CREATE TABLE 제품별가능한프로그램(
    제품정보ID REFERENCES 제품정보(제품정보ID),
    프로그램사양ID REFERENCES 프로그램사양(프로그램사양ID),
    
    CONSTRAINT PK_제품별가능한프로그램 PRIMARY KEY (제품정보ID, 프로그램사양ID)
);