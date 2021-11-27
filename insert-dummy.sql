--
-- Note!
--
-- This SQL file is written for test purpose.
-- Please generate SQL file using laptopman_crawler/cralwer.py and use it.
--

INSERT INTO 프로그램 VALUES('마인크래프트', '잼민이들이 환장하는 게임', 'https://cdn.icon-icons.com/icons2/2699/PNG/512/minecraft_logo_icon_168974.png');
INSERT INTO 프로그램 VALUES('서든어택', '넥슨에서 만든 플래시 총 게임', 'https://lh3.googleusercontent.com/proxy/BxN2JQX1ZxbzbRDevtjXutSyds-GrMvjgNwLfbaTj7RCufeQ2zkil625_PMbothycbQIVRbrdxzciA-iWWrizh5h38_dyq9hE_Z_M69rt4eL6SCPfgWKfh0w');
INSERT INTO 프로그램 VALUES('메이플스토리', '대한민국 1티어였던 게임 그러나 지금은', 'https://t1.daumcdn.net/cfile/tistory/99718D3359C47D6233');
INSERT INTO 프로그램 VALUES('당근마켓', '네고왕! 아이템을 최대한 저렴하게 구매하라!', NULL);
INSERT INTO 프로그램 VALUES('롤', '팀원들과 협동하여 새로운 언어들을 학습해보자.', NULL);
INSERT INTO 프로그램 VALUES('지뢰찾기', '어린 시절, 컴퓨터실의', NULL);
INSERT INTO 프로그램 VALUES('핀볼', '공치기 게임', NULL);

INSERT INTO 운영체제 VALUES('Windows');
INSERT INTO 운영체제 VALUES('Mac OS');
INSERT INTO 운영체제 VALUES('Linux');
INSERT INTO 운영체제 VALUES('Free DOS');

INSERT INTO 프로그램지원운영체제 VALUES('마인크래프트', 'Windows');
INSERT INTO 프로그램지원운영체제 VALUES('마인크래프트', 'Mac OS');
INSERT INTO 프로그램지원운영체제 VALUES('마인크래프트', 'Linux');
INSERT INTO 프로그램지원운영체제 VALUES('서든어택', 'Windows');
INSERT INTO 프로그램지원운영체제 VALUES('메이플스토리', 'Windows');

INSERT INTO CPU VALUES('4500U', 'x86', 'AMD', 4769, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('4700U', 'x86', 'AMD', 5520, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('i5-10210U', 'x86', 'Intel', 2969, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('E6300', 'x86', 'Intel', 437, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('E8400', 'x86', 'Intel', 713, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('E6600', 'x86', 'Intel', 546, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('i3-3210', 'x86', 'Intel', 575, 'Geekbench Multi-Core');
INSERT INTO CPU VALUES('i5-4690', 'x86', 'Intel', 2909, 'Geekbench Multi-Core');

INSERT INTO GPU VALUES('RTX 2080', 'Nvidia', 25914, '3DMark Fire Strike');
INSERT INTO GPU VALUES('GTX 1080', 'Nvidia', 20791, '3DMark Fire Strike');
INSERT INTO GPU VALUES('RTX 2070', 'Nvidia', 19979, '3DMark Fire Strike');
INSERT INTO GPU VALUES('GTX 1070', 'Nvidia', 16836, '3DMark Fire Strike');
INSERT INTO GPU VALUES('GTX 1660 Ti', 'Nvidia', 14684, '3DMark Fire Strike');
INSERT INTO GPU VALUES('Intel HD Graphics 4000', 'Intel', 554, '3DMark Fire Strike');
INSERT INTO GPU VALUES('GT 710', 'Nvidia', 989, '3DMark Fire Strike');
INSERT INTO GPU VALUES('Geforce 6600 GT', 'Nvidia', 200, '3DMark Fire Strike');
INSERT INTO GPU VALUES('Geforce 7600 GT', 'Nvidia', 300, '3DMark Fire Strike');
INSERT INTO GPU VALUES('Geforce 9600 GT', 'Nvidia', 350, '3DMark Fire Strike');

INSERT INTO 프로그램사양 VALUES(0, '마인크래프트', '최소사양', 'i3-3210', 'Intel HD Graphics 4000', 2048);
INSERT INTO 프로그램사양 VALUES(0, '마인크래프트', '권장사양', 'i5-4690', 'GT 710', 4096);
INSERT INTO 프로그램사양 VALUES(0, '서든어택', '최소사양', 'E6300', 'Geforce 7600 GT', 2048);
INSERT INTO 프로그램사양 VALUES(0, '서든어택', '권장사양', 'E8400', 'Geforce 9600 GT', 4096);
INSERT INTO 프로그램사양 VALUES(0, '메이플스토리', '권장사양', 'E6600', 'Geforce 6600 GT', 4096);

INSERT INTO 제품정보 VALUES('1', '레노버 보급형', NULL, '레노버', '2021-11-01', 'i5-10210U', 'Intel HD Graphics 4000', 2048, 'Windows', '15.6', '16:9', '1920x1080', '2Kg');
INSERT INTO 제품정보 VALUES('2', '레노버 중급형', NULL, '레노버', '2021-10-01', 'i5-10210U', 'Intel HD Graphics 4000', 4096, 'Windows', '15.6', '16:9', '1920x1080', '1.8Kg');
INSERT INTO 제품정보 VALUES('3', '삼성 고급형', NULL, '삼성', '2021-09-01', '4700U', 'GTX 1070', 8192, 'Windows', '15.6', '16:9', '1920x1080', '1.6Kg');
INSERT INTO 제품정보 VALUES('4', '맥북', NULL, '애플', '2021-05-01', '4500U', 'RTX 2070', 8192, 'Mac OS', '13', '16:10', '2560x1600', '1.3Kg');

INSERT INTO 제품옵션 VALUES('1', '1', 'SSD 256GB', 320000);
INSERT INTO 제품옵션 VALUES('2', '1', 'SSD 512GB', 360000);
INSERT INTO 제품옵션 VALUES('3', '1', 'SSD 1TB', 510000);
INSERT INTO 제품옵션 VALUES('4', '2', 'SSD 256GB', 530000);
INSERT INTO 제품옵션 VALUES('5', '2', 'SSD 512GB', 580000);
INSERT INTO 제품옵션 VALUES('6', '3', 'SSD 512GB', 620000);
INSERT INTO 제품옵션 VALUES('7', '4', 'SSD 256GB', 1010000);