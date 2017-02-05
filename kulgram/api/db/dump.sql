CREATE SCHEMA `kulgram` ;
use `kulgram`;
CREATE TABLE `kulgram`.`anggota` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `nama` VARCHAR(100) NOT NULL,
  `alamat` VARCHAR(255) NULL,
  `gender` CHAR(1) NULL,
  PRIMARY KEY (`id`));
