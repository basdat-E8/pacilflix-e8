CREATE TABLE CONTRIBUTORS (
    id UUID PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    jenis_kelamin INTEGER NOT NULL,
    kewarganegaraan VARCHAR(50) NOT NULL
);

CREATE TABLE PENULIS_SKENARIO (
    id UUID PRIMARY KEY, 
    FOREIGN KEY (id) REFERENCES CONTRIBUTORS (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PEMAIN (
    id UUID PRIMARY KEY, 
    FOREIGN KEY (id) REFERENCES CONTRIBUTORS (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SUTRADARA (
    id UUID PRIMARY KEY, 
    FOREIGN KEY (id) REFERENCES CONTRIBUTORS (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TAYANGAN (
    id UUID PRIMARY KEY, 
    judul VARCHAR(100) NOT NULL,
    sinopsis VARCHAR(255) NOT NULL,
    asal_negara VARCHAR(50) NOT NULL,
    sinopsis_trailer VARCHAR(255) NOT NULL,
    url_video_trailer VARCHAR(255) NOT NULL,
    release_date_trailer DATE NOT NULL,
    id_sutradara UUID,
    FOREIGN KEY (id_sutradara) REFERENCES SUTRADARA (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PENGGUNA (
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    id_tayangan UUID,
    negara_asal VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PAKET (
    nama VARCHAR(50) PRIMARY KEY,
    harga INTEGER NOT NULL CHECK (harga > 0),
    resolusi_layar VARCHAR(50) NOT NULL
);

CREATE TABLE DUKUNGAN_PERANGKAT (
    nama_paket VARCHAR(50),
    dukungan_perangkat VARCHAR(50),
    PRIMARY KEY (nama_paket, dukungan_perangkat),
    FOREIGN KEY (nama_paket) REFERENCES PAKET (nama) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TRANSACTION (
    username VARCHAR(50),
    start_date_time DATE,
    end_date_time DATE,
    nama_paket VARCHAR(50),
    metode_pembayaran VARCHAR(50) NOT NULL,
    timestamp_pembayaran TIMESTAMP NOT NULL,
    PRIMARY KEY (username, start_date_time),
    FOREIGN KEY (username) REFERENCES PENGGUNA (username) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (nama_paket) REFERENCES PAKET (nama) ON UPDATE CASCADE ON DELETE CASCADE  
);

CREATE TABLE MEMAINKAN_TAYANGAN (
    id_tayangan UUID,
    id_pemain UUID,
    PRIMARY KEY (id_tayangan, id_pemain),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_pemain) REFERENCES PEMAIN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE MENULIS_SKENARIO_TAYANGAN (
    id_tayangan UUID,
    id_penulis_skenario UUID,
    PRIMARY KEY (id_tayangan, id_penulis_skenario),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_penulis_skenario) REFERENCES PENULIS_SKENARIO (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE GENRE_TAYANGAN (
    id_tayangan UUID,
    genre VARCHAR(50),
    PRIMARY KEY (id_tayangan, genre),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE   
);

CREATE TABLE PERUSAHAAN_PRODUKSI (
    nama VARCHAR(100) PRIMARY KEY
);

CREATE TABLE PERSETUJUAN (
    nama VARCHAR(100),
    id_tayangan UUID,
    tanggal_persetujuan DATE,
    durasi INTEGER NOT NULL CHECK (durasi > 0),
    biaya INTEGER NOT NULL CHECK (biaya > 0),
    tanggal_mulai_penayangan DATE NOT NULL,
    PRIMARY KEY (nama, id_tayangan, tanggal_persetujuan),
    FOREIGN KEY (nama) REFERENCES PERUSAHAAN_PRODUKSI (nama) ON UPDATE CASCADE ON DELETE CASCADE,    
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE   
);

CREATE TABLE SERIES (
    id_tayangan UUID PRIMARY KEY,
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE FILM (
    id_tayangan UUID PRIMARY KEY,
    url_video_film VARCHAR(255) NOT NULL,
    release_date_film DATE NOT NULL,
    durasi_film INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE EPISODE (
    id_series UUID,
    sub_judul VARCHAR(100),
    sinopsis VARCHAR(255) NOT NULL,
    durasi INTEGER NOT NULL DEFAULT 0,
    url_video VARCHAR(255) NOT NULL,
    release_date DATE NOT NULL,
    PRIMARY KEY (id_series, sub_judul),
    FOREIGN KEY (id_series) REFERENCES SERIES (id_tayangan) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ULASAN (
    id_tayangan UUID,
    username VARCHAR(50),
    timestamp TIMESTAMP,
    rating INTEGER NOT NULL DEFAULT 0,
    deskripsi VARCHAR(255),
    PRIMARY KEY (username, timestamp),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES PENGGUNA (username) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE DAFTAR_FAVORIT (
    timestamp TIMESTAMP,
    username VARCHAR(50),
    judul VARCHAR(50) NOT NULL,
    PRIMARY KEY (timestamp, username),
    FOREIGN KEY (username) REFERENCES PENGGUNA (username) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TAYANGAN_MEMILIKI_DAFTAR_FAVORIT (
    id_tayangan UUID,
    timestamp TIMESTAMP,
    username VARCHAR(50),
    PRIMARY KEY (id_tayangan, timestamp, username),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (timestamp, username) REFERENCES DAFTAR_FAVORIT (timestamp, username) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE RIWAYAT_NONTON (
    id_tayangan UUID,
    username VARCHAR(50),
    start_date_time TIMESTAMP,
    end_date_time TIMESTAMP NOT NULL,
    PRIMARY KEY (username, start_date_time),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES PENGGUNA (username) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TAYANGAN_TERUNDUH (
    id_tayangan UUID,
    username VARCHAR(50),
    timestamp TIMESTAMP,
    PRIMARY KEY (id_tayangan, timestamp, username),
    FOREIGN KEY (id_tayangan) REFERENCES TAYANGAN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (username) REFERENCES PENGGUNA (username) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO CONTRIBUTORS (id, nama, jenis_kelamin, kewarganegaraan) VALUES
('8d1cb54b-819a-44c8-ba28-c38c8550974f', 'George Martinez', 1, 'Slovenia'),
('a6adf770-62c5-45d5-afd5-283f59c2d49d', 'Hannah Wagner', 1, 'Congo'),
('e24d04c5-ecd6-4bf7-94e3-6e02e388a509', 'Jennifer Rodriguez', 0, 'Thailand'),
('143be010-b863-414a-8e19-fe087070eedc', 'Victoria Williams', 1, 'Italy'),
('7cb1f098-acaa-4bc6-81f9-1eb68c66f25f', 'Carol Lawson', 1, 'Seychelles'),
('e56c743f-d12a-47eb-a4af-994fd4ec17ac', 'Krista Brown', 0, 'Ethiopia'),
('27709e97-4df5-4da1-b6b7-adb1fdde62af', 'Kelly Taylor', 0, 'Barbados'),
('28b54163-ed1e-4ff4-9909-f0c1c5c963cd', 'Thomas Francis', 1, 'Slovakia (Slovak Republic)'),
('46f2239c-17c1-4554-b71b-19cc83d5f433', 'Stacey Reed', 1, 'Norway'),
('56adcb8b-0485-434f-9c1d-c71920608439', 'Jenna Johns', 1, 'South Georgia and the South Sandwich Islands'),
('141e06b3-1576-4096-806b-4320872adead', 'Terrance Wheeler', 0, 'Uzbekistan'),
('12f02dc3-1e45-42cd-a4ca-55604ea215c8', 'Michael Smith', 1, 'Costa Rica'),
('a6f26c1d-ac87-47a5-9b39-e00e8778a337', 'Jason Parrish', 1, 'Cayman Islands'),
('5fb52596-7f6e-4f67-82b7-6dfeb2aaf99e', 'Michael Hart', 0, 'Saint Lucia'),
('b3954a6c-d00b-4e22-8267-90e79a8a11b8', 'Wesley Steele', 1, 'Comoros'),
('d4ad64be-3538-47c5-a0e3-21b05a56382a', 'Amy Glover', 0, 'Sierra Leone'),
('72fce25e-44cc-45db-9f16-cb6c5640d660', 'Ronald Hull', 1, 'Bermuda'),
('53518aef-66aa-4589-8892-ad6f14eea736', 'Kristen Gross', 1, 'Nicaragua'),
('41df98fd-5ba4-471f-9f38-47814a64c3c6', 'Tommy Rodriguez', 0, 'Liechtenstein'),
('1f92edc7-f55e-4073-96f4-be94a75caab6', 'Joanne Lindsey', 0, 'India'),
('bffca223-cc59-43b5-905b-81fb47690014', 'Mrs. Holly Lee MD', 0, 'Hong Kong'),
('528f05c4-c85a-4b0d-8158-ec6ca5e84f53', 'Janet Edwards', 1, 'Tonga'),
('d70446a0-5472-402f-af3f-7be2c76cdb2b', 'Ashley Petty', 0, 'Falkland Islands (Malvinas)'),
('928b722a-fe55-4c3a-953f-5d00db072210', 'Eddie Perkins', 0, 'Jersey'),
('24779344-e41a-4cfa-b204-ffe2695785cd', 'Heather Garrett', 1, 'Jordan'),
('a1b149c2-da75-402f-af4d-ebdd743611a2', 'Sherry Edwards', 0, 'Seychelles'),
('49c3083e-42ce-4572-b890-df127a2d4980', 'Thomas Jenkins', 0, 'Bulgaria'),
('9518b4d4-a10d-4b65-ae33-61c1543aeb2c', 'Pamela Montgomery', 0, 'Slovenia'),
('8d05d1b2-6162-46bc-901e-71c5eae7c5e3', 'Kayla Fowler', 0, 'Kyrgyz Republic'),
('8d7769c2-9651-4cf0-bab2-9745e4b6aa16', 'Karen Patterson', 0, 'Switzerland'),
('161be287-50b8-4925-af18-f439efde9e8b', 'Sean Morgan', 1, 'Suriname'),
('83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7', 'Sarah Brown', 1, 'Bermuda'),
('30c4e68c-17e8-49ba-8fe2-9174056b3434', 'James Phillips', 1, 'Morocco'),
('f267e7b1-e6c8-4a05-8edd-5b470a5ec31d', 'Ryan Nunez', 0, 'North Macedonia'),
('12b9233f-5987-4307-9e94-2490f747e7f3', 'Mr. Jason Moore', 0, 'Monaco'),
('bb038544-7a99-4b67-9bfb-e11e372f84d6', 'Alicia Morales', 0, 'Peru'),
('fbbfc0f5-1e2b-42e6-b2cf-97e7f46cd06b', 'David Stanley', 0, 'Congo'),
('ef4afdcb-a732-4c80-8d44-210284a19945', 'Jessica Wilson', 1, 'Micronesia'),
('4488136e-80a7-44a4-bcd7-10f1186135bc', 'Kathy Sanchez', 0, 'Libyan Arab Jamahiriya'),
('15c1a6d0-37e9-45f6-9a7f-3bc358890e1b', 'Lucas Sharp', 0, 'Australia'),
('eb6ab85c-868d-4dbe-ac01-d502add1f214', 'Brent Macdonald III', 0, 'Lithuania'),
('327c2a6b-68cc-4e96-9941-ee6e82dfbeb7', 'Erin Zuniga', 1, 'Palau'),
('afd99824-35a6-4d10-85af-6ace12dc4b75', 'Jason Patterson DVM', 1, 'Cameroon'),
('0f2cb87b-4e53-4b06-88ee-22d76465b360', 'Richard Barnes', 1, 'Svalbard & Jan Mayen Islands'),
('24cf3e02-93c2-4101-a585-392553405522', 'Carla Rollins', 0, 'China'),
('abfb283f-a294-4b4f-8cd9-0b1d06397485', 'Robert Klein', 0, 'Ukraine'),
('c9cbefc3-2499-45a2-ad61-2bf7b284b620', 'Timothy Schmitt', 0, 'American Samoa'),
('afb9c367-2d22-4408-bc1e-12e866e5449a', 'Shannon Johnson', 0, 'Malta'),
('7d7178ea-c64e-4d27-8965-a8492cd7a53b', 'Steven Osborne', 1, 'Canada'),
('f3c01564-e099-400a-8321-9f36f19b59db', 'Mikayla Oconnell', 0, 'Kyrgyz Republic'),
('5b26f2b4-8c4e-4eed-8abf-5308b4f7ecd6', 'Isaac Thomas', 0, 'Belize'),
('305cbf4f-90b6-46c8-b209-25a63bdbbbaf', 'Henry Reyes', 1, 'Turks and Caicos Islands'),
('1f3b8bff-2852-498b-86b5-3b6ce81b453f', 'Crystal Berry', 1, 'Bangladesh'),
('5fe567fc-9494-4fd7-b3a2-35d21e9244ed', 'Carla Adkins', 0, 'Iran'),
('ebb237c6-bda4-4905-b1f9-b9fd13ab456b', 'Sarah Rodriguez', 1, 'El Salvador'),
('46dc8dee-821a-48ac-a796-5be71434219c', 'Jonathan Houston', 0, 'Mauritania'),
('97377a5c-9582-4ef2-95e5-2bd79075337f', 'Denise Sullivan', 0, 'Morocco'),
('ec9b1610-7bbc-445c-98ae-cb9433322644', 'Robert Martinez', 1, 'Malawi'),
('692d11af-7efd-4fed-980f-3cf0e4d6c606', 'Jennifer Griffin', 0, 'Jordan'),
('601dd9ad-866e-4b89-bf92-fec3773cf0bc', 'Robin Jenkins', 1, 'Suriname'),
('2bf74a63-e8f1-485d-a1d0-346b121863ea', 'Amy Young', 1, 'Northern Mariana Islands'),
('16a7de85-0818-4cd6-b242-f58e099b45f0', 'Jennifer Gibson', 0, 'Sri Lanka'),
('47b3b0a7-2018-4caa-84b5-8740561536f2', 'Deanna Travis', 0, 'Nepal'),
('8fe54194-dd30-4692-a3c5-a78579acdcf4', 'Michael Villa', 1, 'Dominica'),
('ba1b76d2-d048-4c30-8732-abef4904f349', 'Heather Jensen', 1, 'Timor-Leste');

INSERT INTO PAKET (nama, harga, resolusi_layar) VALUES
('premium', 1000000, 'Full HD'),
('standard', 400000, 'HD'),
('basic', 125000, 'Standard');

INSERT INTO PERUSAHAAN_PRODUKSI (nama) VALUES
('Anthony and Sons'),
('Farmer, Wright and Jefferson'),
('Edwards-Horne'),
('Morris, Ramirez and Sharp'),
('Andrews, Luna and Pollard'),
('Murphy, Mcgrath and Wiggins'),
('Stevens Group'),
('Campbell and Sons'),
('Meadows, Little and Hatfield'),
('Shelton LLC'),
('Chang-Pineda'),
('Butler, Murphy and Morton'),
('Mejia-Brown'),
('Juarez, Green and Soto'),
('Vasquez, Taylor and Brown');

INSERT INTO PENULIS_SKENARIO (id) VALUES
('5fb52596-7f6e-4f67-82b7-6dfeb2aaf99e'),
('ec9b1610-7bbc-445c-98ae-cb9433322644'),
('a6f26c1d-ac87-47a5-9b39-e00e8778a337'),
('161be287-50b8-4925-af18-f439efde9e8b'),
('5b26f2b4-8c4e-4eed-8abf-5308b4f7ecd6'),
('41df98fd-5ba4-471f-9f38-47814a64c3c6'),
('c9cbefc3-2499-45a2-ad61-2bf7b284b620'),
('24779344-e41a-4cfa-b204-ffe2695785cd'),
('abfb283f-a294-4b4f-8cd9-0b1d06397485'),
('1f92edc7-f55e-4073-96f4-be94a75caab6'),
('7d7178ea-c64e-4d27-8965-a8492cd7a53b'),
('ebb237c6-bda4-4905-b1f9-b9fd13ab456b'),
('eb6ab85c-868d-4dbe-ac01-d502add1f214'),
('bffca223-cc59-43b5-905b-81fb47690014'),
('f3c01564-e099-400a-8321-9f36f19b59db'),
('bb038544-7a99-4b67-9bfb-e11e372f84d6'),
('ef4afdcb-a732-4c80-8d44-210284a19945'),
('15c1a6d0-37e9-45f6-9a7f-3bc358890e1b'),
('46dc8dee-821a-48ac-a796-5be71434219c'),
('143be010-b863-414a-8e19-fe087070eedc'),
('16a7de85-0818-4cd6-b242-f58e099b45f0'),
('97377a5c-9582-4ef2-95e5-2bd79075337f'),
('4488136e-80a7-44a4-bcd7-10f1186135bc'),
('30c4e68c-17e8-49ba-8fe2-9174056b3434'),
('53518aef-66aa-4589-8892-ad6f14eea736'),
('1f3b8bff-2852-498b-86b5-3b6ce81b453f'),
('8d05d1b2-6162-46bc-901e-71c5eae7c5e3'),
('72fce25e-44cc-45db-9f16-cb6c5640d660'),
('692d11af-7efd-4fed-980f-3cf0e4d6c606'),
('a1b149c2-da75-402f-af4d-ebdd743611a2');

INSERT INTO PEMAIN (id) VALUES
('abfb283f-a294-4b4f-8cd9-0b1d06397485'),
('601dd9ad-866e-4b89-bf92-fec3773cf0bc'),
('16a7de85-0818-4cd6-b242-f58e099b45f0'),
('ebb237c6-bda4-4905-b1f9-b9fd13ab456b'),
('143be010-b863-414a-8e19-fe087070eedc'),
('a6adf770-62c5-45d5-afd5-283f59c2d49d'),
('afb9c367-2d22-4408-bc1e-12e866e5449a'),
('afd99824-35a6-4d10-85af-6ace12dc4b75'),
('0f2cb87b-4e53-4b06-88ee-22d76465b360'),
('692d11af-7efd-4fed-980f-3cf0e4d6c606'),
('27709e97-4df5-4da1-b6b7-adb1fdde62af'),
('24cf3e02-93c2-4101-a585-392553405522'),
('12f02dc3-1e45-42cd-a4ca-55604ea215c8'),
('b3954a6c-d00b-4e22-8267-90e79a8a11b8'),
('7d7178ea-c64e-4d27-8965-a8492cd7a53b'),
('ef4afdcb-a732-4c80-8d44-210284a19945'),
('5b26f2b4-8c4e-4eed-8abf-5308b4f7ecd6'),
('f267e7b1-e6c8-4a05-8edd-5b470a5ec31d'),
('bb038544-7a99-4b67-9bfb-e11e372f84d6'),
('47b3b0a7-2018-4caa-84b5-8740561536f2'),
('a6f26c1d-ac87-47a5-9b39-e00e8778a337'),
('1f3b8bff-2852-498b-86b5-3b6ce81b453f'),
('1f92edc7-f55e-4073-96f4-be94a75caab6'),
('eb6ab85c-868d-4dbe-ac01-d502add1f214'),
('e24d04c5-ecd6-4bf7-94e3-6e02e388a509'),
('305cbf4f-90b6-46c8-b209-25a63bdbbbaf'),
('49c3083e-42ce-4572-b890-df127a2d4980'),
('30c4e68c-17e8-49ba-8fe2-9174056b3434'),
('2bf74a63-e8f1-485d-a1d0-346b121863ea'),
('a1b149c2-da75-402f-af4d-ebdd743611a2'),
('24779344-e41a-4cfa-b204-ffe2695785cd'),
('ec9b1610-7bbc-445c-98ae-cb9433322644'),
('97377a5c-9582-4ef2-95e5-2bd79075337f'),
('d4ad64be-3538-47c5-a0e3-21b05a56382a'),
('fbbfc0f5-1e2b-42e6-b2cf-97e7f46cd06b'),
('ba1b76d2-d048-4c30-8732-abef4904f349'),
('83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('56adcb8b-0485-434f-9c1d-c71920608439'),
('8fe54194-dd30-4692-a3c5-a78579acdcf4'),
('327c2a6b-68cc-4e96-9941-ee6e82dfbeb7');

INSERT INTO SUTRADARA (id) VALUES
('83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('47b3b0a7-2018-4caa-84b5-8740561536f2'),
('f3c01564-e099-400a-8321-9f36f19b59db'),
('1f3b8bff-2852-498b-86b5-3b6ce81b453f'),
('ebb237c6-bda4-4905-b1f9-b9fd13ab456b'),
('41df98fd-5ba4-471f-9f38-47814a64c3c6'),
('8d1cb54b-819a-44c8-ba28-c38c8550974f'),
('bb038544-7a99-4b67-9bfb-e11e372f84d6'),
('5fe567fc-9494-4fd7-b3a2-35d21e9244ed'),
('97377a5c-9582-4ef2-95e5-2bd79075337f');

INSERT INTO TAYANGAN (id, judul, sinopsis, asal_negara, sinopsis_trailer, url_video_trailer, release_date_trailer, id_sutradara) VALUES
('c4007755-8765-4ebb-8f70-eeee171afff8', 'Game Somebody.', 'Explain Democrat direction whether exactly effort dinner. Help my among present series. Dinner reason certain around quite. State fast collection just. Score federal challenge where.', 'Mauritania', 'Work reality by result understand while wall. Serious media toward company. Especially look personal now late health. Class participant ground assume community form range.', 'https://www.todd-smith.org/', '2022-08-08', '47b3b0a7-2018-4caa-84b5-8740561536f2'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'There.', 'From unit piece. Surface reason general street set majority blue soldier. Also strong indicate similar itself certainly dark. Per fine direction however quickly no weight. Available suggest trouble send sort argue.', 'Cocos (Keeling) Islands', 'Military analysis reason let on. Her all hair so quickly give onto. Ability exactly my mind word we team put. Throughout consumer chair run local economy.', 'https://www.welch.info/', '2018-07-20', 'f3c01564-e099-400a-8321-9f36f19b59db'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'Late Here Traditional.', 'Left finish before near bank camera family set. Involve too including. Five clearly blood most.', 'Myanmar', 'Street my morning spend theory data kitchen. Name debate parent nearly trial.', 'https://murray-carter.com/', '2018-10-05', '41df98fd-5ba4-471f-9f38-47814a64c3c6'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'Travel Stay Floor.', 'Road take administration third what range. Building prove better hair want field. Surface account possible three price game school type. Team industry at close represent as stay. Former catch after rate part. The outside guess skill left foot adult.', 'Togo', 'Use guess itself best. Truth case interesting two worry task.', 'http://mckinney.com/', '2018-09-07', 'f3c01564-e099-400a-8321-9f36f19b59db'),
('3efc2349-9de9-489b-871f-149dda75e020', 'West Late Fact.', 'Air despite similar behind very. Chance upon ask still husband effort. Some move audience up think. Cost discover popular. Work turn without continue education. Available work civil point.', 'Algeria', 'Pull term recent history. Though either standard help.', 'https://stokes.net/', '2023-04-04', '8d1cb54b-819a-44c8-ba28-c38c8550974f'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'Instead Effect Common.', 'Phone TV serious station attention treat test. Whatever computer economy have. Century above foot next page or area different. Manager science special create safe fill.', 'Cameroon', 'Daughter chair reason seat fall forget start. Compare author rest seat expert describe fund everybody.', 'http://www.moore.com/', '2018-02-07', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'Worker Whom Avoid.', 'Hot establish girl consumer. Area stock agent stand agreement figure watch. Natural energy fast however.', 'Cyprus', 'Next government anything cause past. Off recently on western even often.', 'http://newman.net/', '2018-05-27', '8d1cb54b-819a-44c8-ba28-c38c8550974f'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'Cut Each.', 'Simple something adult mean. Which throw tell positive. Agreement along only. Material project perform nation who especially ability. Either magazine research low discover while. Agent under economy capital true.', 'United Arab Emirates', 'Teacher save stay movement anyone special why. Put region pretty mouth trip raise minute. Artist some agent admit.', 'http://foster-schmidt.org/', '2015-07-05', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'Travel Look Conference.', 'Common ground reflect guess ground size sport. Idea arrive throw short unit moment third. Let another sort player course news party.', 'Cook Islands', 'Address capital increase kid bank. Can foot might whole left prove. Lead agree tree move measure agent specific.', 'https://chung.com/', '2020-06-18', '97377a5c-9582-4ef2-95e5-2bd79075337f'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'Toward Majority.', 'None service mention bill too. Activity offer key officer a when according. Prepare somebody say per energy outside again. Pm score mean effort billion reflect.', 'Togo', 'Raise close wait word letter. More indeed process bill anyone off. Executive well more quality very short.', 'https://padilla.com/', '2022-11-15', '47b3b0a7-2018-4caa-84b5-8740561536f2'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Score Follow Feel.', 'Class seven friend deal quality major commercial. Case style many game society. Crime let build respond get care federal. Bring song everybody though health.', 'Dominica', 'They worry daughter number project hotel red. Free chance since stand system their stay.', 'https://www.dixon.com/', '2014-08-23', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'I Attention May.', 'While sign leader night. A side four clearly responsibility. Letter different media dog TV front. To station find music building. Ten outside difference attorney.', 'Turkey', 'Section we executive common organization. Agency industry effort.', 'https://www.richard.com/', '2019-11-27', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'Dark Analysis.', 'Director whatever myself. Crime space property. Also two create a. Role trip lot shoulder suddenly husband appear fear. Professor reach involve party until message.', 'Mayotte', 'Size assume individual everyone community give senior. Moment everybody compare trade indeed issue.', 'http://www.lawson.com/', '2022-06-01', 'ebb237c6-bda4-4905-b1f9-b9fd13ab456b'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'Use.', 'Until toward at house generation will. Hit how law necessary. Happy education magazine film instead can look. Know more population media break eat music. Answer of manage pay pick not me phone.', 'Finland', 'Hotel sure interview parent process. Teach deal avoid country. Industry defense time my clear small treat.', 'https://www.kirk-howard.com/', '2014-11-21', '5fe567fc-9494-4fd7-b3a2-35d21e9244ed'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'Product Congress.', 'Similar debate me same. Reflect go popular discover stop. Same whole drive wife necessary phone face. Campaign building art. Movie now left other theory actually. Century herself television economic head against.', 'Saint Pierre and Miquelon', 'Owner opportunity might wall PM language. Pattern realize everything. Tax too land glass.', 'http://www.bailey-schultz.com/', '2021-01-11', '41df98fd-5ba4-471f-9f38-47814a64c3c6');

INSERT INTO MEMAINKAN_TAYANGAN (id_tayangan, id_pemain) VALUES
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'afb9c367-2d22-4408-bc1e-12e866e5449a'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'ba1b76d2-d048-4c30-8732-abef4904f349'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', '7d7178ea-c64e-4d27-8965-a8492cd7a53b'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'a1b149c2-da75-402f-af4d-ebdd743611a2'),
('3efc2349-9de9-489b-871f-149dda75e020', 'a1b149c2-da75-402f-af4d-ebdd743611a2'),
('86be6b24-7d30-4656-816d-7642358a6dc9', '601dd9ad-866e-4b89-bf92-fec3773cf0bc'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'a6adf770-62c5-45d5-afd5-283f59c2d49d'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'bb038544-7a99-4b67-9bfb-e11e372f84d6'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'e24d04c5-ecd6-4bf7-94e3-6e02e388a509'),
('6d4fa649-939f-4691-9d75-6333f023ee51', '7d7178ea-c64e-4d27-8965-a8492cd7a53b'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', '143be010-b863-414a-8e19-fe087070eedc'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '305cbf4f-90b6-46c8-b209-25a63bdbbbaf'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'a6f26c1d-ac87-47a5-9b39-e00e8778a337'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'ba1b76d2-d048-4c30-8732-abef4904f349'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', '0f2cb87b-4e53-4b06-88ee-22d76465b360'),
('3efc2349-9de9-489b-871f-149dda75e020', '12f02dc3-1e45-42cd-a4ca-55604ea215c8'),
('8fc98448-222b-47aa-a033-77369c7286cf', '97377a5c-9582-4ef2-95e5-2bd79075337f'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'ebb237c6-bda4-4905-b1f9-b9fd13ab456b'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'f267e7b1-e6c8-4a05-8edd-5b470a5ec31d'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '305cbf4f-90b6-46c8-b209-25a63bdbbbaf'),
('c4007755-8765-4ebb-8f70-eeee171afff8', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'ba1b76d2-d048-4c30-8732-abef4904f349'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', '7d7178ea-c64e-4d27-8965-a8492cd7a53b'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'fbbfc0f5-1e2b-42e6-b2cf-97e7f46cd06b'),
('6d4fa649-939f-4691-9d75-6333f023ee51', '30c4e68c-17e8-49ba-8fe2-9174056b3434'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', '49c3083e-42ce-4572-b890-df127a2d4980'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'ebb237c6-bda4-4905-b1f9-b9fd13ab456b'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'ef4afdcb-a732-4c80-8d44-210284a19945'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', '49c3083e-42ce-4572-b890-df127a2d4980'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'a1b149c2-da75-402f-af4d-ebdd743611a2'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', '8fe54194-dd30-4692-a3c5-a78579acdcf4'),
('3efc2349-9de9-489b-871f-149dda75e020', '24779344-e41a-4cfa-b204-ffe2695785cd'),
('86be6b24-7d30-4656-816d-7642358a6dc9', '8fe54194-dd30-4692-a3c5-a78579acdcf4'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'fbbfc0f5-1e2b-42e6-b2cf-97e7f46cd06b'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'ef4afdcb-a732-4c80-8d44-210284a19945'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '1f92edc7-f55e-4073-96f4-be94a75caab6'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', '327c2a6b-68cc-4e96-9941-ee6e82dfbeb7'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'a6adf770-62c5-45d5-afd5-283f59c2d49d'),
('8fc98448-222b-47aa-a033-77369c7286cf', '2bf74a63-e8f1-485d-a1d0-346b121863ea'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'ec9b1610-7bbc-445c-98ae-cb9433322644'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', '97377a5c-9582-4ef2-95e5-2bd79075337f'),
('8fc98448-222b-47aa-a033-77369c7286cf', '30c4e68c-17e8-49ba-8fe2-9174056b3434'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'a6f26c1d-ac87-47a5-9b39-e00e8778a337'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'a6f26c1d-ac87-47a5-9b39-e00e8778a337'),
('3efc2349-9de9-489b-871f-149dda75e020', 'f267e7b1-e6c8-4a05-8edd-5b470a5ec31d'),
('3efc2349-9de9-489b-871f-149dda75e020', 'a6adf770-62c5-45d5-afd5-283f59c2d49d'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', '83cdc5cb-eb76-4cef-8e6e-0bf3ad5d14f7'),
('86be6b24-7d30-4656-816d-7642358a6dc9', '1f92edc7-f55e-4073-96f4-be94a75caab6'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', '1f3b8bff-2852-498b-86b5-3b6ce81b453f');

INSERT INTO MENULIS_SKENARIO_TAYANGAN (id_tayangan, id_penulis_skenario) VALUES
('6d4fa649-939f-4691-9d75-6333f023ee51', '41df98fd-5ba4-471f-9f38-47814a64c3c6'),
('8fc98448-222b-47aa-a033-77369c7286cf', '72fce25e-44cc-45db-9f16-cb6c5640d660'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'f3c01564-e099-400a-8321-9f36f19b59db'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'bffca223-cc59-43b5-905b-81fb47690014'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', '1f92edc7-f55e-4073-96f4-be94a75caab6'),
('3efc2349-9de9-489b-871f-149dda75e020', '692d11af-7efd-4fed-980f-3cf0e4d6c606'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', '46dc8dee-821a-48ac-a796-5be71434219c'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'bffca223-cc59-43b5-905b-81fb47690014'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', '692d11af-7efd-4fed-980f-3cf0e4d6c606'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'a6f26c1d-ac87-47a5-9b39-e00e8778a337'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'a1b149c2-da75-402f-af4d-ebdd743611a2'),
('3efc2349-9de9-489b-871f-149dda75e020', 'bb038544-7a99-4b67-9bfb-e11e372f84d6'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', '15c1a6d0-37e9-45f6-9a7f-3bc358890e1b'),
('86be6b24-7d30-4656-816d-7642358a6dc9', '46dc8dee-821a-48ac-a796-5be71434219c'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '46dc8dee-821a-48ac-a796-5be71434219c'),
('86be6b24-7d30-4656-816d-7642358a6dc9', '97377a5c-9582-4ef2-95e5-2bd79075337f'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', '692d11af-7efd-4fed-980f-3cf0e4d6c606'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '53518aef-66aa-4589-8892-ad6f14eea736'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'ec9b1610-7bbc-445c-98ae-cb9433322644'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', '4488136e-80a7-44a4-bcd7-10f1186135bc'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'a1b149c2-da75-402f-af4d-ebdd743611a2'),
('3efc2349-9de9-489b-871f-149dda75e020', 'eb6ab85c-868d-4dbe-ac01-d502add1f214'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', '8d05d1b2-6162-46bc-901e-71c5eae7c5e3'),
('8fc98448-222b-47aa-a033-77369c7286cf', '143be010-b863-414a-8e19-fe087070eedc'),
('6d4fa649-939f-4691-9d75-6333f023ee51', '4488136e-80a7-44a4-bcd7-10f1186135bc'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', '4488136e-80a7-44a4-bcd7-10f1186135bc'),
('c4007755-8765-4ebb-8f70-eeee171afff8', '1f3b8bff-2852-498b-86b5-3b6ce81b453f'),
('3efc2349-9de9-489b-871f-149dda75e020', '7d7178ea-c64e-4d27-8965-a8492cd7a53b'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', '1f3b8bff-2852-498b-86b5-3b6ce81b453f'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'bffca223-cc59-43b5-905b-81fb47690014'),
('6d4fa649-939f-4691-9d75-6333f023ee51', '1f92edc7-f55e-4073-96f4-be94a75caab6'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'c9cbefc3-2499-45a2-ad61-2bf7b284b620'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'a1b149c2-da75-402f-af4d-ebdd743611a2'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'abfb283f-a294-4b4f-8cd9-0b1d06397485'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'abfb283f-a294-4b4f-8cd9-0b1d06397485');

INSERT INTO GENRE_TAYANGAN (id_tayangan, genre) VALUES
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'Historical'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'Mystery'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'Fantasy'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'Supernatural'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'Horror'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Mystery'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'Mystery'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'Mystery'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'Animation'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'Supernatural');

INSERT INTO PERSETUJUAN (nama, id_tayangan, tanggal_persetujuan, durasi, biaya, tanggal_mulai_penayangan) VALUES
('Chang-Pineda', '86be6b24-7d30-4656-816d-7642358a6dc9', '2024-01-18', 58, 272631676, '2024-05-11'),
('Juarez, Green and Soto', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', '2023-07-15', 39, 280944335, '2025-03-13'),
('Stevens Group', '6d4fa649-939f-4691-9d75-6333f023ee51', '2023-05-07', 36, 272699905, '2024-07-29'),
('Butler, Murphy and Morton', '3efc2349-9de9-489b-871f-149dda75e020', '2024-04-13', 39, 907220048, '2024-10-13'),
('Edwards-Horne', 'c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '2023-05-09', 60, 979520199, '2025-02-13'),
('Meadows, Little and Hatfield', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2023-12-19', 46, 842565289, '2024-10-09'),
('Juarez, Green and Soto', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', '2023-07-06', 36, 873014735, '2025-03-15'),
('Meadows, Little and Hatfield', 'fc14d4ac-8bca-4603-9d7b-2c08a877e3de', '2024-03-15', 51, 236738666, '2024-09-15'),
('Meadows, Little and Hatfield', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', '2024-01-21', 54, 643268174, '2025-01-24'),
('Stevens Group', 'fc14d4ac-8bca-4603-9d7b-2c08a877e3de', '2024-03-14', 46, 287591987, '2024-10-09'),
('Campbell and Sons', '86be6b24-7d30-4656-816d-7642358a6dc9', '2023-09-25', 38, 618850122, '2024-07-01'),
('Campbell and Sons', 'fc14d4ac-8bca-4603-9d7b-2c08a877e3de', '2023-08-21', 50, 944975006, '2024-06-27'),
('Shelton LLC', 'f09353c9-7de0-4b17-b01f-13c0d1547bda', '2024-03-30', 44, 709827109, '2024-12-23'),
('Murphy, Mcgrath and Wiggins', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', '2023-12-17', 47, 274466125, '2024-08-13'),
('Chang-Pineda', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2024-01-24', 43, 483021714, '2024-09-18'),
('Mejia-Brown', 'c2393b42-a688-4697-a8c0-95b589bdfc46', '2023-05-06', 42, 286742409, '2024-11-14'),
('Shelton LLC', '86be6b24-7d30-4656-816d-7642358a6dc9', '2023-10-30', 36, 835298222, '2025-02-12'),
('Vasquez, Taylor and Brown', 'c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '2023-11-22', 34, 564415529, '2024-09-06'),
('Mejia-Brown', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2023-08-23', 30, 154680374, '2024-05-01'),
('Shelton LLC', '8fc98448-222b-47aa-a033-77369c7286cf', '2024-04-14', 40, 785321236, '2024-07-18'),
('Butler, Murphy and Morton', 'c4007755-8765-4ebb-8f70-eeee171afff8', '2023-06-06', 56, 563822953, '2024-12-26'),
('Anthony and Sons', '86be6b24-7d30-4656-816d-7642358a6dc9', '2023-05-03', 35, 814447747, '2024-11-26'),
('Chang-Pineda', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2023-10-11', 57, 845419203, '2024-09-23'),
('Chang-Pineda', '86be6b24-7d30-4656-816d-7642358a6dc9', '2023-07-24', 47, 995418874, '2025-04-19'),
('Campbell and Sons', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2023-06-30', 38, 625850508, '2024-12-16'),
('Farmer, Wright and Jefferson', '3efc2349-9de9-489b-871f-149dda75e020', '2023-05-20', 55, 476407784, '2024-12-31'),
('Butler, Murphy and Morton', '8fc98448-222b-47aa-a033-77369c7286cf', '2024-04-06', 46, 140625950, '2025-04-17'),
('Shelton LLC', '8fc98448-222b-47aa-a033-77369c7286cf', '2023-12-01', 36, 547075028, '2024-06-21'),
('Chang-Pineda', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2023-06-09', 31, 567499245, '2024-07-05'),
('Anthony and Sons', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', '2024-03-11', 58, 317323836, '2024-09-21'),
('Vasquez, Taylor and Brown', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2023-06-12', 50, 631797207, '2025-02-18'),
('Shelton LLC', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2024-02-10', 40, 456478458, '2024-09-19'),
('Morris, Ramirez and Sharp', 'c2393b42-a688-4697-a8c0-95b589bdfc46', '2023-05-03', 42, 829697002, '2025-02-28'),
('Shelton LLC', '6cf270fe-f45a-4628-b53c-9689dc2fe6a4', '2024-01-27', 41, 340384433, '2024-09-19'),
('Murphy, Mcgrath and Wiggins', 'c2393b42-a688-4697-a8c0-95b589bdfc46', '2023-09-18', 37, 472081235, '2024-07-27'),
('Mejia-Brown', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2023-08-28', 53, 160683437, '2024-08-05'),
('Edwards-Horne', '8fc98448-222b-47aa-a033-77369c7286cf', '2023-07-30', 48, 382155295, '2024-09-30'),
('Meadows, Little and Hatfield', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2023-07-10', 31, 846022423, '2025-02-24'),
('Mejia-Brown', '6d4fa649-939f-4691-9d75-6333f023ee51', '2023-07-01', 33, 726654092, '2025-03-13'),
('Meadows, Little and Hatfield', 'fc14d4ac-8bca-4603-9d7b-2c08a877e3de', '2023-11-06', 53, 616677265, '2024-11-21'),
('Stevens Group', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2023-12-14', 31, 572462150, '2024-07-21'),
('Murphy, Mcgrath and Wiggins', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', '2023-12-20', 55, 497617736, '2024-05-19'),
('Chang-Pineda', 'f171bdd0-1afb-46a2-a756-437a9f59d284', '2024-03-15', 41, 610326430, '2024-10-14'),
('Shelton LLC', 'c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '2023-11-10', 50, 101580379, '2024-05-20'),
('Edwards-Horne', '3efc2349-9de9-489b-871f-149dda75e020', '2023-05-27', 30, 681965459, '2024-09-18'),
('Juarez, Green and Soto', '6cf270fe-f45a-4628-b53c-9689dc2fe6a4', '2023-12-18', 47, 251154875, '2024-09-18'),
('Meadows, Little and Hatfield', '8fc98448-222b-47aa-a033-77369c7286cf', '2023-07-19', 44, 825734459, '2024-06-25'),
('Shelton LLC', '86be6b24-7d30-4656-816d-7642358a6dc9', '2023-05-10', 58, 536406759, '2024-09-19'),
('Edwards-Horne', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2023-11-28', 34, 621228376, '2024-10-23'),
('Butler, Murphy and Morton', '2d446e42-cde8-4724-ac51-372d6c8c498d', '2023-07-10', 45, 647025244, '2025-03-16');

INSERT INTO SERIES (id_tayangan) VALUES
('3efc2349-9de9-489b-871f-149dda75e020'),
('2d446e42-cde8-4724-ac51-372d6c8c498d'),
('6d4fa649-939f-4691-9d75-6333f023ee51'),
('c4007755-8765-4ebb-8f70-eeee171afff8'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda');

INSERT INTO FILM (id_tayangan, url_video_film, release_date_film, durasi_film) VALUES
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'http://wood.com/', '2023-06-30', 123),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'http://zimmerman.net/', '2023-08-25', 111),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'https://ramos-wilson.info/', '2023-06-06', 188),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'http://www.phillips-eaton.net/', '2023-10-15', 199),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'http://www.sutton.net/', '2024-02-20', 177),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'https://edwards.com/', '2023-10-10', 87),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'https://www.moore.info/', '2023-08-07', 198),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'https://www.davidson.info/', '2023-09-08', 203),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'http://www.thompson.com/', '2023-07-20', 220),
('3efc2349-9de9-489b-871f-149dda75e020', 'https://fowler.com/', '2023-10-22', 83);

INSERT INTO EPISODE (id_series, sub_judul, sinopsis, durasi, url_video, release_date) VALUES
('3efc2349-9de9-489b-871f-149dda75e020', 'Huge follow modern.', 'Usually oil stand might kid. Many culture focus other prevent. Community book toward give born region smile.', 47, 'https://miller.biz/', '2023-11-19'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'Bad necessary.', 'Writer according hotel nice kitchen edge. Create around product everything indicate.', 46, 'http://decker-harper.biz/', '2024-02-12'),
('3efc2349-9de9-489b-871f-149dda75e020', 'Performance.', 'Power think talk skill find. Heart meeting of imagine along. Family loss cup scientist Mrs know.', 31, 'http://www.clements.com/', '2024-03-07'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'Little above.', 'Front expert no stage effort few water. Career group activity health attack worry. Loss to movement talk usually save.', 26, 'http://anderson.net/', '2024-01-14'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'Something recent.', 'Think station meeting dinner simple oil. Mind account western case. Beautiful game better of.', 34, 'http://www.fisher-bell.com/', '2024-03-24'),
('3efc2349-9de9-489b-871f-149dda75e020', 'Drive now.', 'Behind hair authority eat energy. Gas father little recognize kitchen decade admit. West pressure certainly magazine.', 25, 'https://www.wagner.com/', '2023-07-11'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Manager indicate.', 'Cover western must floor industry go those finish. Thing suddenly leave work trial body late. Stage which defense rate. Start night type develop.', 43, 'http://www.clay.org/', '2023-06-14'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Last.', 'Student quite black ball. Pick history hand imagine. Star role management hear line relationship be.', 34, 'http://www.miller-glass.com/', '2024-04-27'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Hit future argue.', 'Week yourself although create newspaper reduce activity cell. Physical lose audience half community. Cell will easy develop.', 54, 'http://holmes-patterson.com/', '2023-12-24'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Until assume.', 'Consider arrive agreement. Wall notice nice term part.', 58, 'http://www.nguyen.com/', '2023-11-29'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'Middle memory.', 'Religious black everyone game election. Many article another language everything. Campaign discuss past rich others.', 48, 'https://hughes.com/', '2024-03-06'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'Class enough.', 'Wide sometimes sort impact way suffer Congress. Discuss reason chair after. Indicate force affect side win statement themselves.', 54, 'https://www.walker.com/', '2024-03-19'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'Career onto.', 'Trouble thousand pretty public field. Reflect total ten future.', 58, 'https://www.wang.net/', '2023-11-06'),
('3efc2349-9de9-489b-871f-149dda75e020', 'Address military create factor.', 'Community see Mr keep painting. American purpose discover city wonder international suffer. Question picture safe policy practice behind.', 55, 'http://coleman.com/', '2023-12-26'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'Walk open picture.', 'Standard step moment condition. People capital music. Near rate bring turn agreement.', 49, 'https://www.howard-rogers.com/', '2023-07-17'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'Bag special.', 'Free choice while miss. Focus move front rate. Hospital gas man score interview. After Mrs small rate old dog professional.', 53, 'http://www.phillips.com/', '2023-11-08'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Put.', 'Perform my return peace. Should east anyone school pay.', 56, 'http://www.howell-jones.com/', '2024-02-18'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Name white.', 'Crime bed woman speech expect foot. Rich live apply that along feeling those happy. Hold product television result leave serious realize.', 50, 'http://brown.com/', '2024-02-08'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'Owner movie reveal site.', 'Herself or magazine yes just each. Agree special writer control walk leg. The even entire note.', 49, 'https://cole.com/', '2024-02-01'),
('3efc2349-9de9-489b-871f-149dda75e020', 'Anyone explain see.', 'Yes could big spring in think against. Program industry against catch. Teach speak sport still brother green military. Woman their they bring direction skill.', 38, 'http://www.wells.com/', '2023-06-05');

INSERT INTO PENGGUNA (username, password, id_tayangan, negara_asal) VALUES
('danielleharding', '@2Vz0yvJ%a', '2d446e42-cde8-4724-ac51-372d6c8c498d', 'Iraq'),
('morenoamanda', 'T2^HLQb8!D', 'a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'Cambodia'),
('curtistroy', 'S8Bw6^nx&^', '6d4fa649-939f-4691-9d75-6333f023ee51', 'Iceland'),
('heatherhutchinson', '6rPJtyc@@4', '6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'Guinea-Bissau'),
('nperkins', '448AzeZu%q', 'f171bdd0-1afb-46a2-a756-437a9f59d284', 'Nepal'),
('thorntonwendy', 'k#04WCEyYi', 'f171bdd0-1afb-46a2-a756-437a9f59d284', 'Bouvet Island (Bouvetoya)'),
('hilllaura', '@37Y8)Mz^K', '6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'Singapore'),
('carolyn64', '#sEymNCn*6', 'fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'Korea'),
('stephanieolson', '_yCDEN+pl8', 'f09353c9-7de0-4b17-b01f-13c0d1547bda', 'Singapore'),
('rbarron', 'JYYx1o0I!3', '8fc98448-222b-47aa-a033-77369c7286cf', 'Kazakhstan');

INSERT INTO ULASAN (id_tayangan, username, timestamp, rating, deskripsi) VALUES
('3efc2349-9de9-489b-871f-149dda75e020', 'thorntonwendy', '2023-09-23 13:53:01.844760', 4, 'Including six fight everyone. Own garden threat. Foot claim space real happy. Order long improve even case seven training.'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'hilllaura', '2023-09-17 23:59:07.527474', 1, 'It main address ball parent special scene property. Night probably evidence else.'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'rbarron', '2023-11-14 13:29:57.796777', 1, 'Those side employee note. Tonight special fire even.'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'curtistroy', '2024-04-13 21:35:14.359439', 2, 'Investment loss development police young. Entire often very view. Onto individual community group protect skill.'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'morenoamanda', '2023-10-11 23:35:12.511078', 1, 'What mission draw former clear small. Thus break though room much hear add.'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'thorntonwendy', '2023-05-25 10:10:07.068538', 2, 'Research ago politics improve western Republican heart. Congress across do. Design crime specific international huge magazine.'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'nperkins', '2024-03-23 13:10:39.079988', 5, 'Science now military now movie item yourself bar. Film series amount watch maybe.'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'carolyn64', '2023-12-29 20:12:44.868162', 1, 'Born senior ready executive. Environment source phone.'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'curtistroy', '2024-01-19 19:20:16.217741', 3, 'Focus glass question successful. Grow during foot last style discussion organization should.'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'stephanieolson', '2023-08-15 04:32:41.281126', 5, 'Fund store condition budget next. Message any question specific analysis. It production woman partner onto.'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'carolyn64', '2023-08-07 16:38:03.404346', 4, 'Attention democratic standard. Drug behind memory leg. Citizen television whom group. Source institution war trial once main business whole.'),
('3efc2349-9de9-489b-871f-149dda75e020', 'morenoamanda', '2023-07-02 19:46:05.396232', 2, 'Form pay final professor. Professor position kind cover outside expect.'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'thorntonwendy', '2023-10-31 16:04:19.609797', 1, 'Boy Congress blood.'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'curtistroy', '2024-04-03 15:55:24.373349', 3, 'Behavior bed low likely.'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'curtistroy', '2023-09-23 16:56:38.310826', 3, 'Speech down power night religious long choose. Issue couple when project all.'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'rbarron', '2023-07-29 04:29:45.879616', 4, 'Admit only very report pull. Fine space summer worry away strong. Decade night wait money large.');

INSERT INTO DAFTAR_FAVORIT (timestamp, username, judul) VALUES
('2024-02-15 04:58:51.991914', 'stephanieolson', 'Into lose citizen between.'),
('2023-12-20 20:10:17.126755', 'rbarron', 'Name window sure.'),
('2023-06-11 13:59:51.156895', 'heatherhutchinson', 'Sister our.'),
('2024-02-19 01:47:20.693912', 'thorntonwendy', 'Not two senior.'),
('2024-01-17 11:27:30.895055', 'curtistroy', 'Speech once.'),
('2023-06-25 13:35:03.584948', 'carolyn64', 'Party build statement.'),
('2023-07-05 04:47:09.020893', 'carolyn64', 'Drop.'),
('2024-02-17 23:27:45.537642', 'rbarron', 'Should.'),
('2024-03-07 02:39:20.059518', 'thorntonwendy', 'Image husband.'),
('2024-01-19 00:14:57.943242', 'danielleharding', 'After hold heavy.'),
('2023-06-09 07:23:56.075654', 'heatherhutchinson', 'Health agree course.'),
('2023-10-12 04:18:22.094982', 'curtistroy', 'So end option.'),
('2023-09-29 10:14:34.905523', 'curtistroy', 'Security push.'),
('2023-05-31 14:09:37.054746', 'thorntonwendy', 'Institution treat customer.'),
('2023-10-22 18:57:15.627551', 'hilllaura', 'Red reveal.'),
('2023-07-14 00:13:48.685991', 'morenoamanda', 'Others enter PM.');

INSERT INTO TAYANGAN_MEMILIKI_DAFTAR_FAVORIT (id_tayangan, timestamp, username) VALUES
('c2393b42-a688-4697-a8c0-95b589bdfc46', '2023-10-22 18:57:15.627551', 'hilllaura'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', '2024-01-17 11:27:30.895055', 'curtistroy'),
('3efc2349-9de9-489b-871f-149dda75e020', '2023-05-31 14:09:37.054746', 'thorntonwendy'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', '2023-06-11 13:59:51.156895', 'heatherhutchinson'),
('8fc98448-222b-47aa-a033-77369c7286cf', '2024-02-15 04:58:51.991914', 'stephanieolson'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2023-07-14 00:13:48.685991', 'morenoamanda'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2024-02-15 04:58:51.991914', 'stephanieolson'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', '2024-01-17 11:27:30.895055', 'curtistroy'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2024-02-19 01:47:20.693912', 'thorntonwendy'),
('8fc98448-222b-47aa-a033-77369c7286cf', '2023-07-05 04:47:09.020893', 'carolyn64'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '2023-09-29 10:14:34.905523', 'curtistroy'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '2023-06-25 13:35:03.584948', 'carolyn64'),
('6d4fa649-939f-4691-9d75-6333f023ee51', '2024-01-19 00:14:57.943242', 'danielleharding'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', '2024-01-19 00:14:57.943242', 'danielleharding'),
('c4007755-8765-4ebb-8f70-eeee171afff8', '2024-02-17 23:27:45.537642', 'rbarron'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', '2023-06-11 13:59:51.156895', 'heatherhutchinson');

INSERT INTO RIWAYAT_NONTON (id_tayangan, username, start_date_time, end_date_time) VALUES
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'thorntonwendy', '2023-09-11 14:01:10.054178', '2023-09-11 16:24:10.054178'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'curtistroy', '2024-04-11 18:30:19.774192', '2024-04-11 19:40:19.774192'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'morenoamanda', '2023-05-27 05:09:37.454618', '2023-05-27 07:43:37.454618'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'nperkins', '2024-02-22 21:33:15.063124', '2024-02-23 00:16:15.063124'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'nperkins', '2024-01-16 00:41:45.815798', '2024-01-16 03:41:45.815798'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'nperkins', '2023-11-30 17:13:41.816238', '2023-11-30 18:29:41.816238'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'morenoamanda', '2023-11-13 02:38:32.381168', '2023-11-13 03:15:32.381168'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'morenoamanda', '2023-09-18 00:31:37.947978', '2023-09-18 00:48:37.947978'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'heatherhutchinson', '2023-08-21 22:44:54.893305', '2023-08-22 00:17:54.893305'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'danielleharding', '2024-03-16 06:46:40.624964', '2024-03-16 07:34:40.624964'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'heatherhutchinson', '2024-02-17 03:23:02.033653', '2024-02-17 05:11:02.033653'),
('3efc2349-9de9-489b-871f-149dda75e020', 'heatherhutchinson', '2023-10-03 04:35:28.693634', '2023-10-03 07:20:28.693634'),
('2c227a2a-d63b-4e77-bfab-321ec6865fac', 'heatherhutchinson', '2023-08-04 02:58:17.772450', '2023-08-04 03:40:17.772450'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'curtistroy', '2023-08-28 04:37:17.791698', '2023-08-28 06:53:17.791698'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'nperkins', '2024-03-24 05:02:56.760804', '2024-03-24 06:18:56.760804'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'curtistroy', '2023-11-09 13:26:43.836367', '2023-11-09 15:37:43.836367'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'thorntonwendy', '2023-08-15 09:41:46.279368', '2023-08-15 10:22:46.279368'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'hilllaura', '2023-09-19 21:59:18.239546', '2023-09-19 22:42:18.239546'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'stephanieolson', '2023-09-28 00:41:38.664746', '2023-09-28 01:34:38.664746'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'morenoamanda', '2023-12-31 18:27:03.614390', '2023-12-31 21:19:03.614390'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'morenoamanda', '2024-02-24 10:18:26.129771', '2024-02-24 10:39:26.129771'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'curtistroy', '2023-07-09 04:21:18.277209', '2023-07-09 04:39:18.277209'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'morenoamanda', '2023-10-22 17:42:29.953544', '2023-10-22 20:42:29.953544'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'curtistroy', '2024-04-28 19:57:56.013048', '2024-04-28 22:54:56.013048');

INSERT INTO TAYANGAN_TERUNDUH (id_tayangan, username, timestamp) VALUES
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'thorntonwendy', '2023-07-15 03:57:42.888288'),
('3efc2349-9de9-489b-871f-149dda75e020', 'stephanieolson', '2024-04-28 11:43:07.262613'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'thorntonwendy', '2024-04-18 19:09:48.844716'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'carolyn64', '2023-10-26 07:05:54.096920'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'danielleharding', '2023-10-18 17:29:52.195882'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'heatherhutchinson', '2024-01-09 13:18:47.308985'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'stephanieolson', '2023-05-10 22:13:12.488028'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'curtistroy', '2023-09-07 13:03:18.093054'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'hilllaura', '2023-11-20 02:19:11.126360'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'nperkins', '2023-05-26 03:54:02.765648'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'curtistroy', '2023-12-08 04:10:48.420830'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'rbarron', '2023-08-25 13:59:18.098629'),
('f171bdd0-1afb-46a2-a756-437a9f59d284', 'rbarron', '2024-01-12 17:37:27.002759'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'hilllaura', '2024-02-20 19:36:39.220493'),
('2d446e42-cde8-4724-ac51-372d6c8c498d', 'stephanieolson', '2024-03-16 07:58:05.478946'),
('8fc98448-222b-47aa-a033-77369c7286cf', 'heatherhutchinson', '2024-04-09 09:28:52.541503'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'carolyn64', '2023-10-12 17:27:31.829269'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'nperkins', '2023-09-21 03:14:35.586996'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'heatherhutchinson', '2024-03-27 12:16:49.131638'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'hilllaura', '2023-12-05 15:22:04.974524'),
('c811fbf1-21fc-419c-aba9-ab5c9cc7bf1a', 'rbarron', '2023-10-14 02:29:27.250131'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'carolyn64', '2024-02-11 08:49:45.698875'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'danielleharding', '2023-06-25 03:19:10.960840'),
('6d4fa649-939f-4691-9d75-6333f023ee51', 'rbarron', '2024-04-13 03:53:59.707352'),
('c4007755-8765-4ebb-8f70-eeee171afff8', 'morenoamanda', '2024-04-02 21:19:50.598050'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'thorntonwendy', '2023-12-01 05:23:33.759554'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'nperkins', '2023-10-26 12:50:37.312398'),
('86be6b24-7d30-4656-816d-7642358a6dc9', 'heatherhutchinson', '2023-05-10 03:34:20.990545'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'stephanieolson', '2024-04-03 07:53:25.017684'),
('6adc5f80-d29b-463a-b5fe-12ba09f80fb8', 'morenoamanda', '2023-07-06 09:09:23.616493'),
('a1f1e38e-bc02-4da5-a2b0-28f70393d504', 'thorntonwendy', '2023-06-03 13:43:21.057117'),
('f09353c9-7de0-4b17-b01f-13c0d1547bda', 'nperkins', '2024-01-03 13:56:21.945449'),
('c2393b42-a688-4697-a8c0-95b589bdfc46', 'carolyn64', '2024-03-05 04:49:24.441041'),
('6cf270fe-f45a-4628-b53c-9689dc2fe6a4', 'thorntonwendy', '2023-07-09 14:32:25.175278'),
('fc14d4ac-8bca-4603-9d7b-2c08a877e3de', 'rbarron', '2024-01-15 21:23:20.036611');

INSERT INTO DUKUNGAN_PERANGKAT (nama_paket, dukungan_perangkat) VALUES
('standard', 'Laptop'),
('standard', 'Television'),
('premium', 'Television'),
('standard', 'Phone'),
('premium', 'Phone'),
('premium', 'Tablet'),
('standard', 'Tablet'),
('basic', 'Tablet'),
('premium', 'Laptop'),
('basic', 'Phone'),
('basic', 'Laptop'),
('basic', 'Television');

INSERT INTO TRANSACTION (username, start_date_time, end_date_time, nama_paket, metode_pembayaran, timestamp_pembayaran) VALUES
('rbarron', '2024-04-13', '2024-06-30', 'premium', 'e-Wallet', '2024-06-05 16:12:45.496031'),
('thorntonwendy', '2023-10-25', '2023-11-02', 'basic', 'Credit Card', '2023-11-01 05:13:05.282113'),
('morenoamanda', '2024-03-16', '2024-04-24', 'premium', 'Bank Transfer', '2024-04-14 17:02:14.822000'),
('stephanieolson', '2024-01-14', '2024-04-12', 'standard', 'e-Wallet', '2024-01-30 14:10:53.464113'),
('thorntonwendy', '2024-04-21', '2024-06-22', 'basic', 'Bank Transfer', '2024-05-03 21:22:23.029462'),
('heatherhutchinson', '2023-10-12', '2023-12-25', 'standard', 'Credit Card', '2023-10-31 05:39:40.522608'),
('carolyn64', '2023-12-19', '2023-12-21', 'basic', 'Credit Card', '2023-12-19 22:34:37.209807'),
('heatherhutchinson', '2023-08-07', '2023-09-26', 'standard', 'e-Wallet', '2023-09-17 06:07:24.249929'),
('danielleharding', '2023-08-28', '2023-10-02', 'premium', 'Bank Transfer', '2023-09-12 02:37:19.330014'),
('hilllaura', '2023-11-18', '2024-01-19', 'premium', 'Bank Transfer', '2023-12-02 12:05:55.478354'),
('rbarron', '2023-05-25', '2023-07-10', 'standard', 'Bank Transfer', '2023-06-19 18:16:22.710167'),
('stephanieolson', '2023-10-21', '2024-01-13', 'standard', 'e-Wallet', '2023-11-14 17:24:11.180969'),
('morenoamanda', '2023-09-20', '2023-09-28', 'basic', 'Credit Card', '2023-09-25 13:33:23.754513'),
('carolyn64', '2023-11-29', '2023-12-26', 'basic', 'e-Wallet', '2023-12-07 09:11:13.547302'),
('thorntonwendy', '2023-12-07', '2023-12-08', 'premium', 'e-Wallet', '2023-12-07 12:13:30.942237'),
('nperkins', '2023-12-27', '2024-01-14', 'standard', 'Bank Transfer', '2024-01-12 19:11:09.440889'),
('curtistroy', '2023-07-24', '2023-08-27', 'basic', 'Credit Card', '2023-08-21 22:38:27.838865'),
('rbarron', '2023-06-16', '2023-08-28', 'premium', 'Bank Transfer', '2023-07-11 00:18:24.758195'),
('carolyn64', '2023-08-03', '2023-08-07', 'premium', 'e-Wallet', '2023-08-04 09:46:46.662039'),
('stephanieolson', '2023-05-09', '2023-05-29', 'basic', 'Credit Card', '2023-05-27 13:57:47.438245'),
('stephanieolson', '2023-07-15', '2023-09-11', 'standard', 'e-Wallet', '2023-07-30 16:16:30.927855'),
('curtistroy', '2023-05-09', '2023-06-29', 'standard', 'Credit Card', '2023-06-12 16:38:36.220905'),
('morenoamanda', '2023-05-18', '2023-06-16', 'basic', 'e-Wallet', '2023-05-28 08:54:01.077772'),
('heatherhutchinson', '2023-05-15', '2023-05-22', 'premium', 'e-Wallet', '2023-05-20 09:49:25.175646');