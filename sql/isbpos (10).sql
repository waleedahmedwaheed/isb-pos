-- phpMyAdmin SQL Dump
-- version 4.5.2
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Nov 27, 2017 at 06:09 AM
-- Server version: 5.7.9-log
-- PHP Version: 7.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `isbpos`
--

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `get_products`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_products` (IN `getid` INT)  NO SQL
SELECT * from product where prod_id = getid$$

DROP PROCEDURE IF EXISTS `loss_insert`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `loss_insert` (IN `lossid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`, `shop_id`, `prod_id` , `loss_id`) 
select l.loss_qty,l.loss_weight,1,l.shop_id,l.prod_id,l.loss_id from loss l
WHERE NOT EXISTS (select s.loss_id from stock s where s.loss_id=lossid)
 and l.loss_status = 0$$

DROP PROCEDURE IF EXISTS `loss_update`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `loss_update` (IN `lossid` INT)  update loss l set l.loss_status = 2 where l.loss_id = lossid$$

DROP PROCEDURE IF EXISTS `pb_update`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pb_update` (IN `PROID` INT)  UPDATE  production_batches
        SET     pb_status = 2
        WHERE   pro_id =  PROID and pb_status = 0$$

DROP PROCEDURE IF EXISTS `pp_update`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pp_update` (IN `PROID` INT)  UPDATE  production_prod
        SET     pp_status = 2
        WHERE   pro_id =  PROID and pp_status = 0$$

DROP PROCEDURE IF EXISTS `pro_stock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_stock` (IN `PROID` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`, `pro_id`,  `shop_id`, `prod_id`) 
SELECT p.p_qty,p.p_weight,'0',p.pro_id,p.shop_id,p.prod_id FROM production_prod p 
WHERE NOT EXISTS (select pro_id from stock where pro_id=PROID) and pro_id = PROID and p.pp_status = 0$$

DROP PROCEDURE IF EXISTS `pro_stock_sub`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_stock_sub` (IN `PROID` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`, `pro_id`,  `shop_id`, `prod_id`) 
SELECT p.pr_qty,p.pr_weight,'1',p.pro_id,p.shop_id,9999 FROM production p 
WHERE NOT EXISTS (select pro_id from stock where pro_id=PROID and prod_id = 9999) and p.pro_id = PROID and p.pro_status = 0$$

DROP PROCEDURE IF EXISTS `pro_update`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pro_update` (IN `PROID` INT)  UPDATE  production  SET pro_status = 2 WHERE pro_id =  PROID and pro_status = 0$$

DROP PROCEDURE IF EXISTS `PUR_INSERT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PUR_INSERT` (IN `PR_ID` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`, `pur_id`, `shop_id`, `prod_id`) 
SELECT (p.qty-p.qty_loss),(p.weight-(p.bird_wgt_loss+p.weight_loss)),'0',pur_id,shop_id,p.prod_id FROM purchase p 
WHERE NOT EXISTS (select pur_id from stock where pur_id=PR_ID) and pur_id = PR_ID and p_status = 0$$

DROP PROCEDURE IF EXISTS `pur_update`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pur_update` (IN `PURID` INT)  update purchase p set p.p_status = 2 where p.pur_id = PURID and p.p_status = 0$$

DROP PROCEDURE IF EXISTS `P_INSERT`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `P_INSERT` (IN `PURC_ID` INT)  NO SQL
update purchase p set p.p_status = 2 where p.pur_id = PURC_ID and p.p_status = 1$$

DROP PROCEDURE IF EXISTS `stock_check`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `stock_check` (IN `shopid` INT, IN `prodid` BIGINT)  select (SUM(CASE WHEN st_inout = 0 THEN qty ELSE 0 END) -
SUM(CASE WHEN st_inout = 1 THEN qty ELSE 0 END)) as qty ,
 (SUM(CASE WHEN st_inout = 0 THEN weight ELSE 0 END) -
SUM(CASE WHEN st_inout = 1 THEN weight ELSE 0 END)) as weight
 from stock s where s.shop_id = shopid and s.prod_id = prodid$$

DROP PROCEDURE IF EXISTS `update_cust_order`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_cust_order` (IN `coid` INT, IN `costatus` INT)  update cust_order c set c.co_status = costatus where c.co_id = coid$$

DROP PROCEDURE IF EXISTS `update_cust_order_detail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_cust_order_detail` (IN `coid` INT, IN `codstatus` INT)  update cust_order_detail c set c.cod_status = codstatus where c.co_id = coid$$

DROP PROCEDURE IF EXISTS `update_cust_pro`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_cust_pro` (IN `coid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`co_id`) 
SELECT co.co_qty,co.co_weight,1, c.shop_id , co.prod_id , co.co_id  FROM cust_order c, cust_order_detail co  
WHERE NOT EXISTS (select co_id from stock where co_id=coid) and c.co_id = coid and c.co_status = 0 and co.cod_status = 0
and c.co_id = co.co_id$$

DROP PROCEDURE IF EXISTS `update_cust_received`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_cust_received` (IN `coid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`co_id`) 
SELECT (co.co_qty - co.rv_qty) as qty,(co.co_weight - co.rv_weight) as weight,0, c.shop_id , co.prod_id , co.co_id  FROM cust_order c, cust_order_detail co  
WHERE NOT EXISTS (select co_id from stock s where s.co_id=coid and s.shop_id=c.shop_id and s.prod_id=co.prod_id and s.st_inout = 0)  
and c.co_id = coid and c.co_status = 1 and c.co_id = co.co_id$$

DROP PROCEDURE IF EXISTS `update_live_appr`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_live_appr` (IN `trid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`tr_id`) 
SELECT (t.s_qty - t.r_qty) as qty,(t.s_weight - t.r_weight) as weight, 0, t.s_shop_id , 9999 , t.tr_id  FROM live_transfer t  
WHERE NOT EXISTS (select s.tr_id from stock s where s.tr_id=trid and s.shop_id = t.s_shop_id and s.prod_id = 9999 and s.st_inout = 0)
 and t.tr_status = 4$$

DROP PROCEDURE IF EXISTS `update_live_bef_loss`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_live_bef_loss` (IN `trid` INT)  update stock s ,
 ( select prod_id,qty,weight,stock_id,(SUM(CASE WHEN st_inout = 0 THEN qty ELSE 0 END) -
SUM(CASE WHEN st_inout = 1 THEN qty ELSE 0 END)) as qtys ,
 (SUM(CASE WHEN st_inout = 0 THEN weight ELSE 0 END) -
SUM(CASE WHEN st_inout = 1 THEN weight ELSE 0 END)) as weights
 from stock s where s.tr_id = trid group by s.prod_id ) q1 
 set s.qty = s.qty+q1.qtys, s.weight = s.weight + q1.weights where 
 s.stock_id = q1.stock_id$$

DROP PROCEDURE IF EXISTS `update_live_loss`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_live_loss` (IN `trid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`tr_id`) 
SELECT (t.s_qty - t.r_qty) as qty,(t.s_weight - t.r_weight) as weight, 1, t.s_shop_id , 9999 , t.tr_id  FROM live_transfer t  
WHERE NOT EXISTS (select s.tr_id from stock s where s.tr_id=trid and s.shop_id = t.s_shop_id and s.prod_id = 9999 and s.st_inout = 0)
 and t.tr_status = 4$$

DROP PROCEDURE IF EXISTS `update_live_rcv`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_live_rcv` (IN `trid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`tr_id`) 
SELECT t.r_qty,t.r_weight,0, t.shop_id , 9999 , t.tr_id  FROM live_transfer t  
WHERE NOT EXISTS (select tr_id from stock s where s.tr_id=trid and s.shop_id = t.shop_id and s.prod_id = 9999)
 and t.tr_id = trid and t.tr_status = 3$$

DROP PROCEDURE IF EXISTS `update_live_transfer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_live_transfer` (IN `trid` INT, IN `trstatus` INT)  update live_transfer t set t.tr_status = trstatus where t.tr_id = trid$$

DROP PROCEDURE IF EXISTS `update_ppr_products`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_ppr_products` (IN `pprid` INT, IN `prstatus` INT)  update ppr_products p set p.pprp_status = prstatus where p.ppr_id = pprid$$

DROP PROCEDURE IF EXISTS `update_processed_appr`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_processed_appr` (IN `pprid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`ppr_id`) 
SELECT (p.s_qty - p.r_qty) as qty,(p.s_weight - p.r_weight) as weight, 0, pp.s_shop_id , p.prod_id , pp.ppr_id  FROM ppr_products p, prod_processed pp  
WHERE NOT EXISTS (select ppr_id from stock s where s.ppr_id=pprid and s.shop_id = pp.s_shop_id and s.prod_id = p.prod_id and s.st_inout = 0)
 and p.ppr_id = pprid and pp.ppr_status = 4 and p.ppr_id = pp.ppr_id$$

DROP PROCEDURE IF EXISTS `update_processed_bef_loss`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_processed_bef_loss` (IN `pprid` INT)  update stock s ,
 ( select prod_id,qty,weight,stock_id,(SUM(CASE WHEN st_inout = 0 THEN qty ELSE 0 END) -
SUM(CASE WHEN st_inout = 1 THEN qty ELSE 0 END)) as qtys ,
 (SUM(CASE WHEN st_inout = 0 THEN weight ELSE 0 END) -
SUM(CASE WHEN st_inout = 1 THEN weight ELSE 0 END)) as weights
 from stock s where s.ppr_id = pprid group by s.prod_id ) q1 
 set s.qty = s.qty+q1.qtys, s.weight = s.weight + q1.weights where 
 s.stock_id = q1.stock_id$$

DROP PROCEDURE IF EXISTS `update_processed_loss`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_processed_loss` (IN `pprid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`ppr_id`) 
SELECT (p.s_qty - p.r_qty) as qty,(p.s_weight - p.r_weight) as weight, 1, pp.s_shop_id , p.prod_id , pp.ppr_id  FROM ppr_products p, prod_processed pp  
WHERE NOT EXISTS (select ppr_id from stock s where s.ppr_id=pprid and s.shop_id = pp.s_shop_id and s.prod_id = p.prod_id and s.st_inout = 0)
 and p.ppr_id = pprid and pp.ppr_status = 4 and p.ppr_id = pp.ppr_id$$

DROP PROCEDURE IF EXISTS `update_processed_rcv`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_processed_rcv` (IN `pprid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`ppr_id`) 
SELECT p.r_qty,p.r_weight,0, pp.shop_id , p.prod_id , pp.ppr_id  FROM ppr_products p, prod_processed pp  
WHERE NOT EXISTS (select ppr_id from stock s where s.ppr_id=pprid and s.shop_id = pp.shop_id and s.prod_id = p.prod_id)
 and p.ppr_id = pprid and pp.ppr_status = 1 and p.ppr_id = pp.ppr_id$$

DROP PROCEDURE IF EXISTS `update_processed_stock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_processed_stock` (IN `pprid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`ppr_id`) 
SELECT p.s_qty,p.s_weight,1, pp.s_shop_id , p.prod_id , pp.ppr_id  FROM ppr_products p, prod_processed pp  
WHERE NOT EXISTS (select ppr_id from stock where ppr_id=pprid) and p.ppr_id = pprid and p.pprp_status = 0 and pp.ppr_status = 0
and p.ppr_id = pp.ppr_id$$

DROP PROCEDURE IF EXISTS `update_production`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_production` (IN `PROID` INT)  SELECT 
   ( select * from stock where stock.pro_id = PROID) ,
   ( select * from production where production.pro_id = PROID)$$

DROP PROCEDURE IF EXISTS `update_prod_processed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_prod_processed` (IN `pprid` INT, IN `prstatus` INT)  update prod_processed pp set pp.ppr_status = prstatus where pp.ppr_id = pprid$$

DROP PROCEDURE IF EXISTS `update_sale`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_sale` (IN `salesid` INT)  update sales s set s.sale_status = 2 where s.sales_id = salesid$$

DROP PROCEDURE IF EXISTS `update_saledetail`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_saledetail` (IN `salesid` INT)  update sales_detail s set s.sd_status = 2 where s.sales_id = salesid and s.sd_status = 0$$

DROP PROCEDURE IF EXISTS `update_salestock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_salestock` (IN `salesid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`sales_id`) 
SELECT s.qty,s.weight,1, sd.shop_id , s.prod_id , s.sales_id  FROM sales_detail s , sales sd  
WHERE NOT EXISTS (select sales_id from stock where sales_id=salesid) and s.sales_id = salesid and s.sd_status = 0 and sd.sale_status = 0
and sd.sales_id=s.sales_id$$

DROP PROCEDURE IF EXISTS `update_transfer_stock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_transfer_stock` (IN `trid` INT)  INSERT INTO `stock`(`qty`, `weight`, `st_inout`,  `shop_id`, `prod_id` ,`tr_id`) 
SELECT t.s_qty,t.s_weight,1, t.s_shop_id , 9999 , t.tr_id  FROM live_transfer t  
WHERE NOT EXISTS (select tr_id from stock where tr_id=trid) and t.tr_id = trid and t.tr_status = 0$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `barcode`
--

DROP TABLE IF EXISTS `barcode`;
CREATE TABLE IF NOT EXISTS `barcode` (
  `bar_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `prod_id` bigint(20) NOT NULL DEFAULT '0',
  `qty` bigint(20) NOT NULL DEFAULT '0',
  `wgt` float NOT NULL DEFAULT '0',
  `barcode` bigint(20) NOT NULL DEFAULT '0',
  `bar_status` int(11) NOT NULL DEFAULT '0',
  `bar_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`bar_id`),
  KEY `FK_barcode_product` (`prod_id`),
  KEY `FK_barcode_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1011 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `barcode`
--

INSERT INTO `barcode` (`bar_id`, `prod_id`, `qty`, `wgt`, `barcode`, `bar_status`, `bar_datetime`, `user_id`) VALUES
(1000, 9999, 2, 5, 0, 0, '2017-09-30 18:05:40', 13),
(1001, 2, 0, 2, 0, 0, '2017-09-30 18:05:54', 13),
(1002, 9999, 5, 10, 0, 0, '2017-09-30 18:06:02', 13),
(1003, 4, 2, 4, 0, 0, '2017-09-30 18:06:20', 13),
(1004, 9999, 5, 10, 0, 0, '2017-10-01 22:23:52', 13),
(1005, 9999, 2, 4, 0, 0, '2017-10-04 12:23:09', 6),
(1006, 9999, 2, 4, 0, 0, '2017-10-05 19:38:58', 6),
(1007, 9999, 1, 2, 0, 0, '2017-10-05 19:46:41', 12),
(1008, 9999, 1, 2, 0, 0, '2017-10-05 20:10:23', 13),
(1009, 9999, 1, 2, 0, 0, '2017-10-05 20:10:46', 12),
(1010, 9999, 1, 2, 0, 0, '2017-10-05 20:15:43', 13);

-- --------------------------------------------------------

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
CREATE TABLE IF NOT EXISTS `customer` (
  `cust_id` int(11) NOT NULL AUTO_INCREMENT,
  `cust_name` varchar(50) NOT NULL,
  `cust_address` varchar(100) NOT NULL,
  `cust_contact` bigint(20) NOT NULL,
  `cust_status` int(11) NOT NULL DEFAULT '0',
  `auth_person` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cust_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customer`
--

INSERT INTO `customer` (`cust_id`, `cust_name`, `cust_address`, `cust_contact`, `cust_status`, `auth_person`) VALUES
(1, 'safroons', 'commercial', 3436562512, 0, 'Waleed'),
(2, 'butt karahi', 'commercial', 3435431231, 0, 'Ahmed'),
(3, 'meatpro', 'asddd', 2321321, 0, 'sadsads');

-- --------------------------------------------------------

--
-- Table structure for table `cust_factor`
--

DROP TABLE IF EXISTS `cust_factor`;
CREATE TABLE IF NOT EXISTS `cust_factor` (
  `fact_id` int(11) NOT NULL AUTO_INCREMENT,
  `cust_id` int(11) NOT NULL,
  `prod_id` int(11) NOT NULL,
  `mandi_fact` float DEFAULT '0',
  `other` float DEFAULT '0',
  `fact_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`fact_id`),
  KEY `FK_cust_factor_customer` (`cust_id`),
  KEY `FK_cust_factor_product` (`prod_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cust_factor`
--

INSERT INTO `cust_factor` (`fact_id`, `cust_id`, `prod_id`, `mandi_fact`, `other`, `fact_status`) VALUES
(1, 2, 1, 1.5, 0, 0),
(2, 2, 2, 1.22, 0, 0),
(4, 3, 9999, 1.2, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `cust_order`
--

DROP TABLE IF EXISTS `cust_order`;
CREATE TABLE IF NOT EXISTS `cust_order` (
  `co_id` int(11) NOT NULL AUTO_INCREMENT,
  `cust_id` int(11) NOT NULL,
  `co_date` date NOT NULL,
  `co_status` int(11) NOT NULL DEFAULT '0',
  `co_datetime` datetime NOT NULL,
  `shop_id` int(11) NOT NULL,
  `rv_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`co_id`),
  KEY `FK_cust_order_customer` (`cust_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cust_order`
--

INSERT INTO `cust_order` (`co_id`, `cust_id`, `co_date`, `co_status`, `co_datetime`, `shop_id`, `rv_datetime`) VALUES
(2, 2, '2017-09-10', 2, '2017-09-09 10:23:07', 5, '2017-09-10 13:50:52'),
(3, 2, '2017-09-30', 2, '2017-09-30 10:52:27', 5, '2017-09-30 22:55:51'),
(4, 2, '2017-09-30', 2, '2017-09-30 10:58:17', 5, '2017-10-01 00:17:45'),
(5, 2, '2017-10-01', 2, '2017-10-01 10:10:09', 5, '2017-10-01 22:19:23'),
(6, 3, '2017-10-05', 2, '2017-10-05 08:47:53', 5, '2017-10-05 20:49:08');

-- --------------------------------------------------------

--
-- Table structure for table `cust_order_amount`
--

DROP TABLE IF EXISTS `cust_order_amount`;
CREATE TABLE IF NOT EXISTS `cust_order_amount` (
  `coa_id` int(11) NOT NULL AUTO_INCREMENT,
  `co_id` int(11) NOT NULL,
  `co_amount` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`coa_id`),
  UNIQUE KEY `Index 3` (`co_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cust_order_amount`
--

INSERT INTO `cust_order_amount` (`coa_id`, `co_id`, `co_amount`) VALUES
(1, 2, 810),
(2, 3, 1000),
(3, 4, 2115),
(4, 5, 549),
(5, 6, 960);

-- --------------------------------------------------------

--
-- Table structure for table `cust_order_detail`
--

DROP TABLE IF EXISTS `cust_order_detail`;
CREATE TABLE IF NOT EXISTS `cust_order_detail` (
  `cod_id` int(11) NOT NULL AUTO_INCREMENT,
  `prod_id` int(11) NOT NULL DEFAULT '0',
  `co_qty` bigint(20) NOT NULL DEFAULT '0',
  `co_weight` float NOT NULL DEFAULT '0',
  `co_id` int(11) NOT NULL,
  `cod_datetime` datetime NOT NULL,
  `cod_status` int(11) NOT NULL DEFAULT '0',
  `prod_price` float NOT NULL DEFAULT '0',
  `price` float NOT NULL DEFAULT '0',
  `rv_qty` bigint(20) DEFAULT NULL,
  `rv_weight` float DEFAULT NULL,
  PRIMARY KEY (`cod_id`),
  KEY `FK_cust_order_detail_cust_order` (`co_id`),
  KEY `FK_cust_order_detail_product` (`prod_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cust_order_detail`
--

INSERT INTO `cust_order_detail` (`cod_id`, `prod_id`, `co_qty`, `co_weight`, `co_id`, `cod_datetime`, `cod_status`, `prod_price`, `price`, `rv_qty`, `rv_weight`) VALUES
(4, 9999, 2, 5, 2, '2017-09-09 23:14:23', 2, 600, 120, 1, 3),
(5, 1, 2, 5, 2, '2017-09-10 00:37:29', 2, 750, 150, 1, 3),
(6, 9999, 10, 20, 3, '2017-09-30 22:53:04', 2, 2000, 100, 5, 10),
(7, 9999, 5, 10, 4, '2017-09-30 22:58:40', 2, 1500, 150, 4, 8),
(8, 2, 0, 5, 4, '2017-10-01 00:14:42', 2, 915, 183, 0, 5),
(9, 2, 0, 5, 5, '2017-10-01 22:11:04', 2, 915, 183, 0, 3),
(10, 9999, 5, 10, 6, '2017-10-05 20:48:38', 2, 1200, 120, 4, 8);

-- --------------------------------------------------------

--
-- Table structure for table `cust_paid`
--

DROP TABLE IF EXISTS `cust_paid`;
CREATE TABLE IF NOT EXISTS `cust_paid` (
  `cp_id` int(11) NOT NULL AUTO_INCREMENT,
  `cp_amount` float NOT NULL DEFAULT '0',
  `cp_datetime` datetime NOT NULL,
  `shop_id` int(11) NOT NULL,
  `u_id` int(11) NOT NULL,
  `cust_id` int(11) NOT NULL,
  `cp_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cp_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cust_paid`
--

INSERT INTO `cust_paid` (`cp_id`, `cp_amount`, `cp_datetime`, `shop_id`, `u_id`, `cust_id`, `cp_status`) VALUES
(1, 200, '2017-09-10 02:52:58', 5, 13, 1, -1),
(2, 200, '2017-09-10 03:09:05', 5, 13, 2, 2),
(3, 100, '2017-09-14 02:42:47', 5, 13, 2, 2),
(4, 2000, '2017-09-30 10:57:28', 5, 13, 2, 2),
(5, 174, '2017-10-01 10:19:36', 5, 13, 2, 2),
(6, 100, '2017-10-05 08:52:30', 5, 6, 3, 2);

-- --------------------------------------------------------

--
-- Table structure for table `daily_rates`
--

DROP TABLE IF EXISTS `daily_rates`;
CREATE TABLE IF NOT EXISTS `daily_rates` (
  `mr_id` int(11) NOT NULL AUTO_INCREMENT,
  `mr_rate` float NOT NULL DEFAULT '0',
  `shop_id` int(11) NOT NULL DEFAULT '0',
  `cur_date` date NOT NULL,
  `sale_rate` float NOT NULL,
  `mr_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=37 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `daily_rates`
--

INSERT INTO `daily_rates` (`mr_id`, `mr_rate`, `shop_id`, `cur_date`, `sale_rate`, `mr_status`) VALUES
(23, 100, 5, '2017-09-14', 130, 0),
(22, 110, 5, '2017-09-10', 120, 0),
(21, 110, 5, '2017-09-09', 120, 0),
(20, 110, 5, '2017-09-03', 120, 0),
(19, 110, 5, '2017-09-02', 120, 0),
(18, 120, 5, '2017-09-01', 130, 0),
(17, 110, 2, '2017-08-30', 120, 0),
(16, 110, 5, '2017-08-30', 120, 0),
(24, 100, 3, '2017-09-14', 120, 0),
(25, 100, 2, '2017-09-14', 120, 0),
(26, 100, 5, '2017-09-23', 100, 0),
(27, 100, 2, '2017-09-24', 100, 0),
(28, 100, 5, '2017-09-24', 100, 0),
(29, 100, 2, '2017-09-25', 100, 0),
(30, 100, 2, '2017-09-30', 120, 0),
(31, 125, 5, '2017-09-30', 100, 0),
(32, 150, 5, '2017-10-01', 150, 0),
(33, 100, 2, '2017-10-04', 150, 0),
(34, 100, 2, '2017-10-05', 150, 0),
(35, 100, 5, '2017-10-05', 150, 0),
(36, 120, 2, '2017-10-07', 150, 0);

-- --------------------------------------------------------

--
-- Table structure for table `farm`
--

DROP TABLE IF EXISTS `farm`;
CREATE TABLE IF NOT EXISTS `farm` (
  `farm_id` int(11) NOT NULL AUTO_INCREMENT,
  `farm_name` varchar(100) NOT NULL,
  `farm_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`farm_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `farm`
--

INSERT INTO `farm` (`farm_id`, `farm_name`, `farm_status`) VALUES
(1, 'farm 1', 0),
(2, 'farm 2', 0),
(3, 'farm name', -1),
(4, 'farm name', -1),
(5, 'farm name', 0),
(6, 'farm name', 0),
(7, 'farm name', 0),
(8, 'farm name', 0),
(9, 'farm name', 0),
(10, 'farm name', 0),
(11, 'farm name', 0),
(12, 'farm name', 0),
(13, 'farm name', 0),
(14, 'farm name', 0),
(15, 'farm name', 0),
(16, 'TEST', 0);

-- --------------------------------------------------------

--
-- Table structure for table `ie_cat`
--

DROP TABLE IF EXISTS `ie_cat`;
CREATE TABLE IF NOT EXISTS `ie_cat` (
  `iecat_id` int(11) NOT NULL AUTO_INCREMENT,
  `ie_desc` varchar(50) NOT NULL,
  `ie_status` int(11) NOT NULL DEFAULT '0',
  `ie_type` int(11) NOT NULL,
  PRIMARY KEY (`iecat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ie_cat`
--

INSERT INTO `ie_cat` (`iecat_id`, `ie_desc`, `ie_status`, `ie_type`) VALUES
(1, 'Bill', 0, 2),
(2, 'TEST INCSS', 0, 1),
(3, 'Stationery', 0, 2);

-- --------------------------------------------------------

--
-- Table structure for table `ie_detail`
--

DROP TABLE IF EXISTS `ie_detail`;
CREATE TABLE IF NOT EXISTS `ie_detail` (
  `ie_id` int(11) NOT NULL AUTO_INCREMENT,
  `ie_amount` float NOT NULL,
  `ie_date` date NOT NULL,
  `ie_dstatus` int(11) NOT NULL DEFAULT '0',
  `iecat_id` int(11) NOT NULL,
  `shop_id` int(11) NOT NULL,
  PRIMARY KEY (`ie_id`),
  KEY `FK_ie_detail_ie_cat` (`iecat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `item_type`
--

DROP TABLE IF EXISTS `item_type`;
CREATE TABLE IF NOT EXISTS `item_type` (
  `it_id` int(11) NOT NULL AUTO_INCREMENT,
  `it_desc` varchar(50) NOT NULL,
  `it_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`it_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `item_type`
--

INSERT INTO `item_type` (`it_id`, `it_desc`, `it_status`) VALUES
(1, 'Retail', 0),
(2, 'Wholesale', 0),
(3, 'Supply', 0),
(4, 'Online', 0);

-- --------------------------------------------------------

--
-- Table structure for table `live_transfer`
--

DROP TABLE IF EXISTS `live_transfer`;
CREATE TABLE IF NOT EXISTS `live_transfer` (
  `tr_id` int(11) NOT NULL AUTO_INCREMENT,
  `s_qty` bigint(20) NOT NULL,
  `s_weight` float NOT NULL,
  `r_qty` bigint(20) NOT NULL DEFAULT '0',
  `r_weight` float NOT NULL DEFAULT '0',
  `shop_id` int(11) NOT NULL,
  `s_shop_id` int(11) NOT NULL,
  `tr_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tr_status` int(11) NOT NULL DEFAULT '0',
  `rcv_datetime` datetime DEFAULT NULL,
  PRIMARY KEY (`tr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `live_transfer`
--

INSERT INTO `live_transfer` (`tr_id`, `s_qty`, `s_weight`, `r_qty`, `r_weight`, `shop_id`, `s_shop_id`, `tr_datetime`, `tr_status`, `rcv_datetime`) VALUES
(3, 50, 100, 40, 80, 2, 5, '2017-09-14 12:35:43', 2, '2017-09-14 12:36:42'),
(4, 100, 200, 80, 180, 2, 5, '2017-09-14 02:28:12', 2, '2017-09-26 11:40:51'),
(5, 60, 120, 60, 120, 3, 5, '2017-09-26 11:26:44', 2, '2017-09-30 10:46:32'),
(6, 100, 200, 100, 200, 3, 5, '2017-10-01 09:47:30', 2, '2017-10-01 09:50:40'),
(9, 60, 120, 60, 120, 1, 3, '2017-10-03 12:17:32', 2, '2017-10-03 12:22:46'),
(10, 23, 41, 13, 31, 1, 2, '2017-10-03 12:25:21', 2, '2017-10-03 12:26:00'),
(11, 35, 70, 35, 70, 2, 5, '2017-10-03 12:33:06', 2, '2017-10-03 12:33:57'),
(12, 50, 100, 40, 80, 2, 5, '2017-10-05 08:19:45', 2, '2017-10-05 08:20:28'),
(13, 20, 40, 10, 20, 2, 5, '2017-10-05 08:21:33', 2, '2017-10-05 08:21:52');

-- --------------------------------------------------------

--
-- Stand-in structure for view `live_transfer_view`
--
DROP VIEW IF EXISTS `live_transfer_view`;
CREATE TABLE IF NOT EXISTS `live_transfer_view` (
`tr_id` int(11)
,`s_qty` bigint(20)
,`s_weight` float
,`r_qty` bigint(20)
,`r_weight` float
,`shop_id` int(11)
,`s_shop_id` int(11)
,`tr_datetime` datetime
,`tr_status` int(11)
,`rcv_datetime` datetime
);

-- --------------------------------------------------------

--
-- Table structure for table `loss`
--

DROP TABLE IF EXISTS `loss`;
CREATE TABLE IF NOT EXISTS `loss` (
  `loss_id` int(11) NOT NULL AUTO_INCREMENT,
  `loss_type` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `loss_qty` int(11) DEFAULT NULL,
  `loss_weight` float NOT NULL,
  `pur_id` int(11) DEFAULT NULL,
  `loss_status` int(11) NOT NULL DEFAULT '0',
  `prod_id` int(11) NOT NULL,
  `loss_datetime` datetime NOT NULL,
  `shop_id` int(11) NOT NULL,
  PRIMARY KEY (`loss_id`),
  KEY `purid_loss` (`pur_id`),
  KEY `prodid_lossd` (`prod_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `loss`
--

INSERT INTO `loss` (`loss_id`, `loss_type`, `type`, `loss_qty`, `loss_weight`, `pur_id`, `loss_status`, `prod_id`, `loss_datetime`, `shop_id`) VALUES
(1, NULL, NULL, 100, 200, 18, 2, 9999, '0000-00-00 00:00:00', 0),
(2, NULL, NULL, 10, 10, NULL, 2, 9999, '2017-09-23 10:25:04', 5),
(3, NULL, NULL, 20, 60, NULL, 2, 9999, '2017-09-30 22:49:35', 5),
(4, NULL, NULL, 5, 10, NULL, 2, 9999, '2017-10-01 22:07:44', 5);

-- --------------------------------------------------------

--
-- Table structure for table `main_menu`
--

DROP TABLE IF EXISTS `main_menu`;
CREATE TABLE IF NOT EXISTS `main_menu` (
  `main_menu_id` int(11) NOT NULL,
  `main_menu_title` varchar(50) NOT NULL,
  `sub_menu_allow` int(11) DEFAULT NULL,
  `menu_order` int(11) DEFAULT NULL,
  `main_page_name` varchar(50) NOT NULL,
  PRIMARY KEY (`main_menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `main_menu`
--

INSERT INTO `main_menu` (`main_menu_id`, `main_menu_title`, `sub_menu_allow`, `menu_order`, `main_page_name`) VALUES
(1, 'Shops', 0, 1, 'shop.php'),
(2, 'Products', 1, 2, ''),
(3, 'Purchase', 0, 3, 'purchase.php'),
(4, 'Rates', 1, 4, ''),
(5, 'Production', 0, 5, 'production.php'),
(6, 'Chiller Transfer', 1, 6, ''),
(7, 'Live Transfer', 1, 7, ''),
(8, 'Loss', 0, 8, 'loss.php'),
(9, 'Stock', 0, 9, 'stock.php'),
(10, 'Customer', 1, 10, ''),
(11, 'Income/Expense', 1, 11, ''),
(12, 'Users', 0, 12, 'user.php'),
(13, 'Barcode Generation', 0, 13, 'prod_barcode.php'),
(14, 'Chiller Received', 0, 14, 'prod_rcv.php'),
(15, 'Live Received', 0, 15, 'live_rcv.php'),
(16, 'Sales', 0, 16, 'sales.php?it_id=1'),
(17, 'Farms', 0, 17, 'farm.php');

-- --------------------------------------------------------

--
-- Table structure for table `menu_allow`
--

DROP TABLE IF EXISTS `menu_allow`;
CREATE TABLE IF NOT EXISTS `menu_allow` (
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `main_menu_id` int(11) NOT NULL,
  `sub_menu_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`row_id`)
) ENGINE=MyISAM AUTO_INCREMENT=221 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `menu_allow`
--

INSERT INTO `menu_allow` (`row_id`, `main_menu_id`, `sub_menu_id`, `user_id`) VALUES
(169, 5, NULL, 14),
(210, 6, NULL, 12),
(209, 5, NULL, 12),
(208, 4, NULL, 12),
(207, 3, NULL, 12),
(170, 6, NULL, 14),
(171, 7, NULL, 14),
(172, 8, NULL, 14),
(173, 9, NULL, 14),
(174, 10, NULL, 14),
(176, 9, NULL, 17),
(177, 15, NULL, 17),
(206, 2, NULL, 12),
(183, 12, NULL, 18),
(205, 1, NULL, 12),
(190, 1, NULL, 4),
(191, 2, NULL, 4),
(192, 3, NULL, 4),
(193, 4, NULL, 4),
(194, 5, NULL, 4),
(195, 6, NULL, 4),
(196, 7, NULL, 4),
(197, 8, NULL, 4),
(198, 9, NULL, 4),
(199, 10, NULL, 4),
(200, 12, NULL, 4),
(201, 13, NULL, 4),
(202, 14, NULL, 4),
(203, 15, NULL, 4),
(204, 16, NULL, 4),
(211, 7, NULL, 12),
(212, 8, NULL, 12),
(213, 9, NULL, 12),
(214, 10, NULL, 12),
(215, 11, NULL, 12),
(216, 12, NULL, 12),
(217, 13, NULL, 12),
(218, 14, NULL, 12),
(219, 15, NULL, 12),
(220, 16, NULL, 12);

-- --------------------------------------------------------

--
-- Table structure for table `ppr_products`
--

DROP TABLE IF EXISTS `ppr_products`;
CREATE TABLE IF NOT EXISTS `ppr_products` (
  `pprp_id` int(11) NOT NULL AUTO_INCREMENT,
  `s_qty` bigint(20) NOT NULL DEFAULT '0',
  `s_weight` float NOT NULL DEFAULT '0',
  `r_qty` bigint(20) NOT NULL DEFAULT '0',
  `r_weight` float NOT NULL DEFAULT '0',
  `pprp_status` int(11) NOT NULL DEFAULT '0',
  `ppr_id` int(11) NOT NULL DEFAULT '0',
  `prod_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`pprp_id`),
  KEY `FK1_ppr` (`ppr_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ppr_products`
--

INSERT INTO `ppr_products` (`pprp_id`, `s_qty`, `s_weight`, `r_qty`, `r_weight`, `pprp_status`, `ppr_id`, `prod_id`) VALUES
(16, 0, 50, 0, 20, 2, 10, 2),
(17, 50, 100, 50, 50, 2, 10, 4),
(18, 5, 10, 3, 6, 2, 11, 5),
(19, 30, 50, 30, 50, 2, 12, 4),
(20, 0, 12, 0, 6, 2, 13, 2),
(21, 10, 20, 5, 10, 2, 13, 4),
(22, 0, 6, 0, 3, 2, 14, 2),
(23, 5, 10, 3, 5, 2, 14, 4),
(24, 0, 6, 0, 3, 2, 15, 2),
(25, 5, 10, 2, 4, 2, 15, 4);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
CREATE TABLE IF NOT EXISTS `product` (
  `prod_id` int(11) NOT NULL AUTO_INCREMENT,
  `prod_name` varchar(50) NOT NULL,
  `pcat_id` int(11) NOT NULL DEFAULT '0',
  `prod_status` int(11) NOT NULL DEFAULT '0',
  `prod_exp` int(11) NOT NULL DEFAULT '0',
  `prod_code` varchar(20) NOT NULL,
  PRIMARY KEY (`prod_id`),
  UNIQUE KEY `Index 3` (`prod_code`),
  KEY `FK_product_product_category` (`pcat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`prod_id`, `prod_name`, `pcat_id`, `prod_status`, `prod_exp`, `prod_code`) VALUES
(1, 'Meat', 2, 0, 0, 'pro1234'),
(2, 'Boneless', 2, 0, 1, '548257689'),
(3, 'Chicken Breast', 4, 0, 2, '1234'),
(4, 'Chicken Leg', 2, 0, 3, '108'),
(5, 'Drum Stick', 2, 0, 1, '1234675');

-- --------------------------------------------------------

--
-- Table structure for table `production`
--

DROP TABLE IF EXISTS `production`;
CREATE TABLE IF NOT EXISTS `production` (
  `pro_id` int(11) NOT NULL AUTO_INCREMENT,
  `pro_date` date NOT NULL,
  `daily_rate` float NOT NULL,
  `pr_qty` int(11) NOT NULL,
  `pr_weight` float NOT NULL,
  `pro_status` int(11) NOT NULL DEFAULT '0',
  `shop_id` int(11) NOT NULL DEFAULT '0',
  `pro_datetime` datetime DEFAULT NULL,
  `dress_weight` float NOT NULL,
  `perc` double DEFAULT NULL,
  PRIMARY KEY (`pro_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `production`
--

INSERT INTO `production` (`pro_id`, `pro_date`, `daily_rate`, `pr_qty`, `pr_weight`, `pro_status`, `shop_id`, `pro_datetime`, `dress_weight`, `perc`) VALUES
(14, '2017-09-14', 100, 100, 200, 2, 5, '2017-09-14 11:49:02', 60, NULL),
(15, '2017-09-14', 100, 110, 270, 2, 5, '2017-09-14 02:23:54', 100, NULL),
(16, '2017-09-23', 100, 100, 200, 2, 5, '2017-09-23 12:26:46', 60, 120),
(17, '2017-10-01', 150, 211, 182, 2, 5, '2017-10-01 09:45:48', 82, 45);

-- --------------------------------------------------------

--
-- Table structure for table `production_batches`
--

DROP TABLE IF EXISTS `production_batches`;
CREATE TABLE IF NOT EXISTS `production_batches` (
  `pb_id` int(11) NOT NULL AUTO_INCREMENT,
  `pb_qty` int(11) NOT NULL DEFAULT '0',
  `pb_weight` float NOT NULL DEFAULT '0',
  `pb_status` int(11) NOT NULL DEFAULT '0',
  `pro_id` int(11) NOT NULL DEFAULT '0',
  `pb_datetime` datetime NOT NULL,
  PRIMARY KEY (`pb_id`),
  KEY `FK_production_batches_production` (`pro_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `production_batches`
--

INSERT INTO `production_batches` (`pb_id`, `pb_qty`, `pb_weight`, `pb_status`, `pro_id`, `pb_datetime`) VALUES
(19, 50, 100, 2, 14, '2017-09-14 12:01:04'),
(20, 50, 100, 2, 14, '2017-09-14 12:01:13'),
(21, 50, 100, 2, 15, '2017-09-14 02:24:16'),
(22, 20, 60, 2, 16, '2017-09-30 10:44:38'),
(23, 100, 200, 2, 17, '2017-10-01 09:45:58');

-- --------------------------------------------------------

--
-- Table structure for table `production_prod`
--

DROP TABLE IF EXISTS `production_prod`;
CREATE TABLE IF NOT EXISTS `production_prod` (
  `pp_id` int(11) NOT NULL AUTO_INCREMENT,
  `prod_id` int(11) NOT NULL DEFAULT '0',
  `p_qty` int(11) NOT NULL DEFAULT '0',
  `p_weight` float NOT NULL DEFAULT '0',
  `pp_status` float NOT NULL DEFAULT '0',
  `pp_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pro_id` int(11) NOT NULL,
  `shop_id` int(11) NOT NULL,
  PRIMARY KEY (`pp_id`),
  KEY `FK_production_prod_production` (`pro_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `production_prod`
--

INSERT INTO `production_prod` (`pp_id`, `prod_id`, `p_qty`, `p_weight`, `pp_status`, `pp_datetime`, `pro_id`, `shop_id`) VALUES
(24, 1, 100, 200, 1, '2017-09-14 00:03:33', 14, 5),
(25, 2, 0, 100, 2, '2017-09-14 00:03:42', 14, 5),
(26, 4, 150, 300, 2, '2017-09-14 00:03:50', 14, 5),
(27, 2, 0, 50, 2, '2017-09-14 02:27:04', 15, 5),
(28, 5, 10, 20, 2, '2017-09-30 22:44:03', 16, 5),
(29, 4, 10, 20, 2, '2017-09-30 22:44:11', 16, 5),
(30, 2, 0, 50, 2, '2017-09-30 22:44:16', 16, 5),
(31, 4, 20, 40, 2, '2017-10-01 21:46:18', 17, 5),
(32, 5, 20, 40, 2, '2017-10-01 21:46:23', 17, 5),
(33, 2, 0, 20, 2, '2017-10-01 21:46:28', 17, 5);

-- --------------------------------------------------------

--
-- Stand-in structure for view `production_view`
--
DROP VIEW IF EXISTS `production_view`;
CREATE TABLE IF NOT EXISTS `production_view` (
`pro_id` int(11)
,`pro_date` date
,`daily_rate` float
,`pr_qty` int(11)
,`pr_weight` float
,`pro_status` int(11)
,`shop_id` int(11)
,`pro_datetime` datetime
);

-- --------------------------------------------------------

--
-- Table structure for table `product_category`
--

DROP TABLE IF EXISTS `product_category`;
CREATE TABLE IF NOT EXISTS `product_category` (
  `pcat_id` int(11) NOT NULL AUTO_INCREMENT,
  `pcat_desc` varchar(40) NOT NULL,
  `pcat_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`pcat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product_category`
--

INSERT INTO `product_category` (`pcat_id`, `pcat_desc`, `pcat_status`) VALUES
(1, 'Cat 1', 0),
(2, 'Chicken', 0),
(3, 'Cat 3', 0),
(4, 'Cat-4', 0);

-- --------------------------------------------------------

--
-- Table structure for table `prod_processed`
--

DROP TABLE IF EXISTS `prod_processed`;
CREATE TABLE IF NOT EXISTS `prod_processed` (
  `ppr_id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) NOT NULL,
  `ppr_date` date NOT NULL,
  `ppr_status` int(11) NOT NULL DEFAULT '0',
  `s_shop_id` int(11) NOT NULL DEFAULT '0',
  `ppr_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ppr_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `prod_processed`
--

INSERT INTO `prod_processed` (`ppr_id`, `shop_id`, `ppr_date`, `ppr_status`, `s_shop_id`, `ppr_datetime`) VALUES
(10, 2, '2017-09-14', 2, 5, '2017-09-14 00:38:43'),
(11, 3, '2017-09-30', 2, 5, '2017-09-30 22:47:39'),
(12, 3, '2017-10-01', 2, 5, '2017-10-01 22:00:31'),
(13, 2, '2017-10-05', 2, 5, '2017-10-05 20:22:22'),
(14, 2, '2017-10-05', 2, 5, '2017-10-05 20:24:22'),
(15, 2, '2017-10-05', 2, 5, '2017-10-05 20:29:42');

-- --------------------------------------------------------

--
-- Stand-in structure for view `prod_processed_view`
--
DROP VIEW IF EXISTS `prod_processed_view`;
CREATE TABLE IF NOT EXISTS `prod_processed_view` (
`ppr_id` int(11)
,`shop_id` int(11)
,`ppr_date` date
,`ppr_status` int(11)
,`s_shop_id` int(11)
,`ppr_datetime` datetime
);

-- --------------------------------------------------------

--
-- Table structure for table `purchase`
--

DROP TABLE IF EXISTS `purchase`;
CREATE TABLE IF NOT EXISTS `purchase` (
  `pur_id` int(11) NOT NULL AUTO_INCREMENT,
  `pur_from` int(11) NOT NULL,
  `party_name` varchar(100) NOT NULL,
  `party_rate` float NOT NULL,
  `mandi_rate` float NOT NULL,
  `pur_date` date NOT NULL,
  `shop_id` int(11) NOT NULL,
  `qty` int(11) NOT NULL,
  `weight` float NOT NULL,
  `driver` varchar(50) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `weight_loss` float DEFAULT NULL,
  `qty_loss` int(11) DEFAULT NULL,
  `bird_wgt_loss` float DEFAULT NULL,
  `p_status` int(11) NOT NULL DEFAULT '0',
  `prod_id` bigint(20) NOT NULL,
  PRIMARY KEY (`pur_id`),
  KEY `shopid_purchase` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `purchase`
--

INSERT INTO `purchase` (`pur_id`, `pur_from`, `party_name`, `party_rate`, `mandi_rate`, `pur_date`, `shop_id`, `qty`, `weight`, `driver`, `vehicle`, `location`, `weight_loss`, `qty_loss`, `bird_wgt_loss`, `p_status`, `prod_id`) VALUES
(18, 2, 'Farm', 120, 100, '2017-09-14', 5, 550, 1100, 'Ahmed', 'abc123', 'Islmabad', 50, 50, 50, 2, 0),
(19, 1, 'ISL Farm', 120, 100, '2017-09-14', 5, 500, 1000, 'waleed', 'abc123', '', 50, 50, 100, 2, 0),
(20, 1, 'Royal', 80, 87.5, '2017-09-26', 5, 476, 886, '', '', '', 0, 6, 16, 2, 0),
(21, 1, 'abc', 100, 125, '2017-09-30', 5, 110, 220, '', '', '', 10, 10, 10, 2, 9999),
(22, 1, 'test', 80, 90, '2017-09-30', 5, 0, 80, '', '', '', 5, 0, 5, 2, 2),
(23, 1, 'ISL Farm', 100, 150, '2017-10-01', 5, 200, 400, '', '', '', 0, 0, 0, 2, 9999),
(24, 1, 'sadasd', 100, 100, '2017-10-01', 5, 120, 200, '', '', '', 0, 0, 0, 2, 9999);

-- --------------------------------------------------------

--
-- Stand-in structure for view `purchase_view`
--
DROP VIEW IF EXISTS `purchase_view`;
CREATE TABLE IF NOT EXISTS `purchase_view` (
`pur_id` int(11)
,`pur_from` int(11)
,`party_name` varchar(100)
,`party_rate` float
,`mandi_rate` float
,`pur_date` date
,`shop_id` int(11)
,`qty` int(11)
,`weight` float
,`driver` varchar(50)
,`vehicle` varchar(50)
,`location` varchar(50)
,`weight_loss` float
,`qty_loss` int(11)
,`bird_wgt_loss` float
,`p_status` int(11)
,`prod_id` bigint(20)
);

-- --------------------------------------------------------

--
-- Table structure for table `rates`
--

DROP TABLE IF EXISTS `rates`;
CREATE TABLE IF NOT EXISTS `rates` (
  `rate_id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) NOT NULL,
  `r_date` date NOT NULL,
  `prod_id` int(11) NOT NULL,
  `pur_price` float DEFAULT '0',
  `sale_price` float NOT NULL,
  `ws_price` float DEFAULT '0',
  `sup_price` float DEFAULT '0',
  `r_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`rate_id`),
  KEY `prod_rates` (`prod_id`),
  KEY `shopid_rates` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `rates`
--

INSERT INTO `rates` (`rate_id`, `shop_id`, `r_date`, `prod_id`, `pur_price`, `sale_price`, `ws_price`, `sup_price`, `r_status`) VALUES
(19, 2, '2017-09-23', 3, 0, 200, 0, 0, 0),
(20, 2, '2017-09-23', 2, 0, 150, 0, 0, 0),
(21, 2, '2017-09-23', 4, 0, 100, 0, 0, 0),
(22, 2, '2017-09-23', 1, 0, 100, 0, 0, 0),
(23, 2, '2017-09-24', 4, 0, 150, 0, 0, 0),
(24, 2, '2017-09-24', 2, 0, 150, 0, 0, 0),
(25, 2, '2017-09-25', 2, 0, 200, 0, 0, 0),
(26, 2, '2017-09-25', 1, 0, 150, 0, 0, 0),
(27, 2, '2017-09-25', 3, 0, 200, 0, 0, 0),
(28, 2, '2017-09-25', 4, 0, 300, 0, 0, 0),
(29, 2, '2017-09-26', 4, 0, 120, 0, 0, 0),
(30, 2, '2017-09-26', 3, 0, 100, 0, 0, 0),
(31, 2, '2017-09-30', 4, 0, 150, 0, 0, 0),
(32, 2, '2017-09-30', 3, 0, 100, 0, 0, 0),
(33, 2, '2017-09-30', 2, 0, 200, 0, 0, 0),
(34, 2, '2017-09-30', 1, 0, 300, 0, 0, 0),
(35, 5, '2017-09-30', 5, 0, 200, 0, 0, 0),
(36, 5, '2017-09-30', 4, 0, 200, 0, 0, 0),
(37, 5, '2017-09-30', 3, 0, 200, 0, 0, 0),
(38, 5, '2017-09-30', 2, 0, 200, 0, 0, 0),
(39, 5, '2017-09-30', 1, 0, 200, 0, 0, 0),
(40, 5, '2017-10-01', 5, 0, 200, 0, 0, 0),
(41, 5, '2017-10-01', 4, 0, 200, 0, 0, 0),
(42, 5, '2017-10-01', 3, 0, 200, 0, 0, 0),
(43, 5, '2017-10-01', 2, 0, 200, 0, 0, 0),
(44, 5, '2017-10-01', 1, 0, 200, 0, 0, 0),
(45, 2, '2017-10-08', 5, 0, 200, 0, 0, 0),
(46, 2, '2017-10-08', 4, 0, 200, 0, 0, 0),
(47, 2, '2017-10-09', 4, 0, 200, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
  `sales_id` int(11) NOT NULL AUTO_INCREMENT,
  `cust_id` int(11) DEFAULT NULL,
  `item_type` int(11) NOT NULL,
  `cash_tendered` float NOT NULL DEFAULT '0',
  `discount` float NOT NULL DEFAULT '0',
  `amount_due` float NOT NULL DEFAULT '0',
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modeofpayment` int(11) DEFAULT NULL,
  `shop_id` int(11) NOT NULL,
  `total` float NOT NULL DEFAULT '0',
  `sale_status` int(11) NOT NULL DEFAULT '0',
  `sales_no` varchar(20) NOT NULL,
  `changed` float NOT NULL DEFAULT '0',
  `roundoff` float DEFAULT NULL,
  PRIMARY KEY (`sales_id`),
  KEY `itemtype_sales` (`item_type`),
  KEY `shopid_sales` (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`sales_id`, `cust_id`, `item_type`, `cash_tendered`, `discount`, `amount_due`, `date_added`, `modeofpayment`, `shop_id`, `total`, `sale_status`, `sales_no`, `changed`, `roundoff`) VALUES
(1, NULL, 1, 0, 0, 850, '2017-09-24 13:58:06', NULL, 2, 850, 2, 'ORD-21-1', 0, 10),
(2, NULL, 1, 0, 0, 300, '2017-09-24 14:45:19', NULL, 2, 300, 2, 'ORD-21-2', 0, 0),
(3, NULL, 1, 1000, 100, 500, '2017-09-25 21:21:33', NULL, 2, 600, 2, 'ORD-21-3', 500, 0),
(4, NULL, 1, 0, 0, 400, '2017-09-25 21:53:18', NULL, 2, 400, 2, 'ORD-21-4', 0, 0),
(5, NULL, 1, 0, 0, 400, '2017-09-25 21:55:28', NULL, 2, 400, 2, 'ORD-21-5', 0, 0),
(6, NULL, 1, 0, 0, 1000, '2017-09-25 21:56:13', NULL, 2, 1000, 2, 'ORD-21-6', 0, 0),
(7, NULL, 1, 2500, 100, 2500, '2017-09-25 22:03:35', NULL, 2, 2600, 2, 'ORD-21-7', 0, 0),
(8, NULL, 1, 0, 0, 0, '2017-09-30 19:06:03', NULL, 5, 0, 0, 'ORD-51-1', 0, NULL),
(9, NULL, 1, 0, 0, 2000, '2017-09-30 20:27:08', NULL, 2, 2000, 2, 'ORD-21-8', 0, 0),
(10, NULL, 1, 0, 0, 2400, '2017-09-30 20:47:25', NULL, 2, 2400, 2, 'ORD-21-10', 0, 0),
(11, NULL, 1, 1000, 100, 560, '2017-09-30 20:59:55', NULL, 2, 660, 2, 'ORD-21-11', 440, 0),
(12, NULL, 1, 0, 0, 600, '2017-10-04 12:23:44', NULL, 2, 600, 2, 'ORD-21-12', 0, 0),
(13, NULL, 1, 0, 0, 600, '2017-10-04 12:24:28', NULL, 2, 600, 2, 'ORD-21-13', 0, 0),
(14, NULL, 1, 0, 0, 600, '2017-10-04 12:25:22', NULL, 2, 600, 2, 'ORD-21-14', 0, 0),
(15, NULL, 1, 0, 0, 600, '2017-10-04 12:26:20', NULL, 2, 600, 2, 'ORD-21-15', 0, 0),
(16, NULL, 1, 0, 0, 300, '2017-10-05 19:46:57', NULL, 2, 300, 2, 'ORD-21-16', 0, 0),
(17, NULL, 1, 0, 0, 300, '2017-10-05 19:47:16', NULL, 2, 300, 2, 'ORD-21-17', 0, 0),
(18, NULL, 1, 0, 0, 300, '2017-10-05 19:48:34', NULL, 2, 300, 2, 'ORD-21-18', 0, 0),
(19, NULL, 1, 0, 0, 300, '2017-10-05 19:48:47', NULL, 2, 300, 2, 'ORD-21-19', 0, 0),
(20, NULL, 1, 0, 0, 225, '2017-10-07 11:46:30', NULL, 2, 225, 2, 'ORD-21-20', 0, 0),
(21, NULL, 1, 0, 0, 225, '2017-10-07 11:48:02', NULL, 2, 225, 2, 'ORD-21-21', 0, 0),
(22, NULL, 1, 0, 0, 225, '2017-10-07 11:49:29', NULL, 2, 225, 2, 'ORD-21-22', 0, 0),
(23, NULL, 1, 0, 0, 225, '2017-10-07 11:50:16', NULL, 2, 225, 2, 'ORD-21-23', 0, 0),
(24, NULL, 1, 0, 0, 225, '2017-10-07 11:50:35', NULL, 2, 225, 2, 'ORD-21-24', 0, 0),
(25, NULL, 1, 0, 0, 225, '2017-10-07 11:51:27', NULL, 2, 225, 2, 'ORD-21-25', 0, 0),
(26, NULL, 1, 0, 0, 225, '2017-10-07 11:53:42', NULL, 2, 225, 2, 'ORD-21-26', 0, 0),
(27, NULL, 1, 100, 0, 53, '2017-10-09 14:46:00', NULL, 2, 53.04, 2, 'ORD-21-27', 47, 0),
(28, NULL, 1, 0, 0, 0, '2017-10-10 11:29:03', NULL, 2, 0, 0, 'ORD-21-28', 0, NULL),
(29, NULL, 1, 0, 0, 0, '2017-10-10 11:29:03', NULL, 2, 0, 0, 'ORD-21-28', 0, NULL),
(30, NULL, 1, 0, 0, 0, '2017-10-10 11:29:03', NULL, 2, 0, 0, 'ORD-21-28', 0, NULL),
(31, NULL, 1, 0, 0, 0, '2017-10-10 11:29:03', NULL, 2, 0, 0, 'ORD-21-28', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sales_detail`
--

DROP TABLE IF EXISTS `sales_detail`;
CREATE TABLE IF NOT EXISTS `sales_detail` (
  `sd_id` int(11) NOT NULL AUTO_INCREMENT,
  `sales_id` int(11) NOT NULL,
  `prod_id` int(11) NOT NULL,
  `qty` int(11) NOT NULL,
  `weight` float NOT NULL,
  `price` float NOT NULL,
  `sd_date` date NOT NULL,
  `sd_status` int(11) NOT NULL DEFAULT '0',
  `sales_no` varchar(30) NOT NULL,
  PRIMARY KEY (`sd_id`),
  KEY `salesid_saledetail` (`sales_id`),
  KEY `prodid_saledetail` (`prod_id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sales_detail`
--

INSERT INTO `sales_detail` (`sd_id`, `sales_id`, `prod_id`, `qty`, `weight`, `price`, `sd_date`, `sd_status`, `sales_no`) VALUES
(1, 1, 9999, 4, 5.5, 550, '2017-09-24', 2, 'ORD-21-1'),
(2, 1, 2, 0, 2, 300, '2017-09-24', 2, 'ORD-21-1'),
(3, 2, 2, 0, 2, 300, '2017-09-24', 2, 'ORD-21-2'),
(4, 3, 9999, 2, 6, 600, '2017-09-25', 2, 'ORD-21-3'),
(5, 4, 9999, 2, 4, 400, '2017-09-25', 2, 'ORD-21-4'),
(6, 5, 9999, 2, 4, 400, '2017-09-25', 2, 'ORD-21-5'),
(7, 6, 9999, 2, 4, 400, '2017-09-25', 2, 'ORD-21-6'),
(8, 6, 2, 0, 2, 400, '2017-09-25', 1, 'ORD-21-6'),
(9, 6, 4, 2, 2, 600, '2017-09-25', 2, 'ORD-21-6'),
(10, 7, 2, 0, 16, 400, '2017-09-25', 1, 'ORD-21-7'),
(11, 7, 2, 0, 4, 400, '2017-09-30', 1, 'ORD-21-7'),
(12, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(13, 7, 2, 0, 4, 400, '2017-09-30', 1, 'ORD-21-7'),
(14, 7, 2, 0, 4, 400, '2017-09-30', 1, 'ORD-21-7'),
(15, 7, 9999, 10, 20, 1200, '2017-09-30', 1, 'ORD-21-7'),
(16, 7, 4, 6, 12, 600, '2017-09-30', 1, 'ORD-21-7'),
(17, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(18, 7, 9999, 5, 10, 1200, '2017-09-30', 1, 'ORD-21-7'),
(19, 7, 9999, 105, 210, 1200, '2017-09-30', 1, 'ORD-21-7'),
(20, 7, 2, 0, 16, 400, '2017-09-30', 1, 'ORD-21-7'),
(21, 7, 2, 0, 16, 400, '2017-09-30', 1, 'ORD-21-7'),
(22, 7, 2, 0, 16, 400, '2017-09-30', 1, 'ORD-21-7'),
(23, 7, 2, 0, 14, 400, '2017-09-30', 1, 'ORD-21-7'),
(24, 7, 2, 0, 12, 400, '2017-09-30', 1, 'ORD-21-7'),
(25, 7, 2, 0, 14, 400, '2017-09-30', 1, 'ORD-21-7'),
(26, 7, 2, 0, 16, 400, '2017-09-30', 1, 'ORD-21-7'),
(27, 7, 9999, 35, 70, 1200, '2017-09-30', 1, 'ORD-21-7'),
(28, 7, 2, 0, 6, 400, '2017-09-30', 1, 'ORD-21-7'),
(29, 7, 9999, 40, 80, 1200, '2017-09-30', 1, 'ORD-21-7'),
(30, 7, 2, 0, 8, 400, '2017-09-30', 1, 'ORD-21-7'),
(31, 7, 4, 2, 4, 600, '2017-09-30', 1, 'ORD-21-7'),
(32, 7, 2, 0, 4, 400, '2017-09-30', 1, 'ORD-21-7'),
(33, 7, 2, 0, 6, 400, '2017-09-30', 1, 'ORD-21-7'),
(34, 7, 2, 0, 6, 400, '2017-09-30', 1, 'ORD-21-7'),
(35, 7, 2, 0, 8, 400, '2017-09-30', 1, 'ORD-21-7'),
(36, 7, 4, 4, 8, 600, '2017-09-30', 1, 'ORD-21-7'),
(37, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(38, 7, 4, 2, 4, 600, '2017-09-30', 1, 'ORD-21-7'),
(39, 7, 9999, 5, 10, 1200, '2017-09-30', 1, 'ORD-21-7'),
(40, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(41, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(42, 7, 4, 2, 4, 600, '2017-09-30', 1, 'ORD-21-7'),
(43, 7, 9999, 2, 4, 480, '2017-09-30', 1, 'ORD-21-7'),
(44, 7, 9999, 5, 10, 1200, '2017-09-30', 1, 'ORD-21-7'),
(45, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(46, 7, 9999, 5, 10, 1200, '2017-09-30', 1, 'ORD-21-7'),
(47, 7, 2, 0, 2, 400, '2017-09-30', 1, 'ORD-21-7'),
(48, 7, 2, 0, 4, 400, '2017-09-30', 2, 'ORD-21-7'),
(49, 7, 9999, 5, 10, 1200, '2017-09-30', 2, 'ORD-21-7'),
(50, 7, 4, 2, 4, 600, '2017-09-30', 2, 'ORD-21-7'),
(51, 9, 2, 0, 4, 400, '2017-09-30', 2, 'ORD-21-8'),
(52, 9, 9999, 5, 10, 1200, '2017-09-30', 2, 'ORD-21-8'),
(53, 10, 9999, 13, 20, 720, '2017-09-30', 2, 'ORD-21-10'),
(54, 11, 9999, 2, 5.5, 660, '2017-09-30', 2, 'ORD-21-11'),
(55, 12, 9999, 2, 4, 600, '2017-10-04', 2, 'ORD-21-12'),
(56, 13, 9999, 2, 4, 600, '2017-10-04', 2, 'ORD-21-13'),
(57, 14, 9999, 2, 4, 600, '2017-10-04', 2, 'ORD-21-14'),
(58, 15, 9999, 2, 4, 600, '2017-10-04', 2, 'ORD-21-15'),
(59, 16, 9999, 1, 2, 300, '2017-10-05', 2, 'ORD-21-16'),
(60, 17, 9999, 1, 2, 300, '2017-10-05', 2, 'ORD-21-17'),
(61, 18, 9999, 1, 2, 300, '2017-10-05', 2, 'ORD-21-18'),
(62, 19, 9999, 1, 2, 300, '2017-10-05', 2, 'ORD-21-19'),
(63, 20, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-20'),
(64, 21, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-21'),
(65, 22, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-22'),
(66, 23, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-23'),
(67, 24, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-24'),
(68, 25, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-25'),
(69, 26, 9999, 1, 1.5, 225, '2017-10-07', 2, 'ORD-21-26'),
(70, 27, 9999, 2, 3, 450, '2017-10-07', 1, 'ORD-21-27'),
(71, 27, 4, 2, 0.5304, 53.04, '2017-10-08', 1, 'ORD-21-27'),
(72, 27, 4, 4, 1.0608, 53.04, '2017-10-09', 1, 'ORD-21-27'),
(73, 27, 4, 1, 0.2652, 53.04, '2017-10-09', 2, 'ORD-21-27');

-- --------------------------------------------------------

--
-- Table structure for table `shop`
--

DROP TABLE IF EXISTS `shop`;
CREATE TABLE IF NOT EXISTS `shop` (
  `shop_id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_name` varchar(50) NOT NULL,
  `shop_address` varchar(100) NOT NULL,
  `shop_contact` varchar(50) NOT NULL,
  `shop_status` int(11) NOT NULL DEFAULT '0',
  `shop_head` int(11) DEFAULT '0',
  PRIMARY KEY (`shop_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `shop`
--

INSERT INTO `shop` (`shop_id`, `shop_name`, `shop_address`, `shop_contact`, `shop_status`, `shop_head`) VALUES
(1, 'G-9 Islamabad', 'G-9 Islamabad', '21312', 0, 0),
(2, 'Commercial', 'Commercial Market', '03435143421', 0, 0),
(3, 'I-9 Islamabad', 'Street # 1 , I-9 Islamabad', '93634674', 0, 0),
(4, 'Satellite Town', 'Satellite Town', '0343123213', 0, 0),
(5, 'Slaughter House', 'commercial', '3221312332', 0, 1),
(6, 'F-10', 'Islamabad', '03435656123', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

DROP TABLE IF EXISTS `stock`;
CREATE TABLE IF NOT EXISTS `stock` (
  `stock_id` int(11) NOT NULL AUTO_INCREMENT,
  `type` int(11) DEFAULT NULL,
  `qty` float NOT NULL,
  `weight` float NOT NULL,
  `st_inout` int(11) NOT NULL,
  `pur_id` int(11) DEFAULT NULL,
  `st_total` float DEFAULT NULL,
  `shop_id` int(11) NOT NULL,
  `wt_total` float DEFAULT NULL,
  `loss_id` int(11) DEFAULT '0',
  `prod_id` bigint(20) NOT NULL,
  `st_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `st_status` int(11) NOT NULL DEFAULT '0',
  `pro_id` bigint(20) DEFAULT NULL,
  `sales_id` bigint(20) DEFAULT NULL,
  `ppr_id` bigint(20) DEFAULT NULL,
  `tr_id` bigint(20) DEFAULT NULL,
  `co_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`stock_id`),
  KEY `pur_stock` (`pur_id`)
) ENGINE=InnoDB AUTO_INCREMENT=349 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`stock_id`, `type`, `qty`, `weight`, `st_inout`, `pur_id`, `st_total`, `shop_id`, `wt_total`, `loss_id`, `prod_id`, `st_date`, `st_status`, `pro_id`, `sales_id`, `ppr_id`, `tr_id`, `co_id`) VALUES
(204, NULL, 500, 1000, 0, 18, NULL, 5, NULL, 0, 9999, '2017-09-13 23:19:34', 0, NULL, NULL, NULL, NULL, NULL),
(205, NULL, 100, 200, 1, 18, NULL, 5, NULL, 1, 9999, '2017-09-13 23:23:01', 0, NULL, NULL, NULL, NULL, NULL),
(207, NULL, 0, 100, 0, NULL, NULL, 5, NULL, 0, 2, '2017-09-14 00:14:33', 0, 14, NULL, NULL, NULL, NULL),
(208, NULL, 150, 300, 0, NULL, NULL, 5, NULL, 0, 4, '2017-09-14 00:14:33', 0, 14, NULL, NULL, NULL, NULL),
(210, NULL, 100, 200, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-14 00:14:33', 0, 14, NULL, NULL, NULL, NULL),
(211, NULL, 50, 100, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-14 00:35:50', 0, NULL, NULL, NULL, 3, NULL),
(212, NULL, 40, 80, 0, NULL, NULL, 2, NULL, 0, 9999, '2017-09-14 00:36:47', 0, NULL, NULL, NULL, 3, NULL),
(213, NULL, 10, 20, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-09-14 00:37:14', 0, NULL, NULL, NULL, 3, NULL),
(215, NULL, 0, 50, 1, NULL, NULL, 5, NULL, 0, 2, '2017-09-14 00:49:05', 0, NULL, NULL, 10, NULL, NULL),
(216, NULL, 50, 100, 1, NULL, NULL, 5, NULL, 0, 4, '2017-09-14 00:49:05', 0, NULL, NULL, 10, NULL, NULL),
(218, NULL, 0, 20, 0, NULL, NULL, 2, NULL, 0, 2, '2017-09-14 00:57:59', 0, NULL, NULL, 10, NULL, NULL),
(219, NULL, 50, 50, 0, NULL, NULL, 2, NULL, 0, 4, '2017-09-14 00:57:59', 0, NULL, NULL, 10, NULL, NULL),
(221, NULL, 0, 30, 0, NULL, NULL, 5, NULL, 0, 2, '2017-09-14 01:03:33', 0, NULL, NULL, 10, NULL, NULL),
(222, NULL, 0, 50, 0, NULL, NULL, 5, NULL, 0, 4, '2017-09-14 01:03:33', 0, NULL, NULL, 10, NULL, NULL),
(224, NULL, 450, 850, 0, 19, NULL, 5, NULL, 0, 9999, '2017-09-14 02:09:48', 0, NULL, NULL, NULL, NULL, NULL),
(225, NULL, 0, 50, 0, NULL, NULL, 5, NULL, 0, 2, '2017-09-14 02:27:33', 0, 15, NULL, NULL, NULL, NULL),
(226, NULL, 110, 270, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-14 02:27:33', 0, 15, NULL, NULL, NULL, NULL),
(227, NULL, 100, 200, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-24 02:28:29', 0, NULL, 0, NULL, 4, NULL),
(229, NULL, 10, 10, 1, NULL, NULL, 5, NULL, 2, 9999, '2017-09-24 11:11:12', 0, NULL, 0, NULL, NULL, NULL),
(233, NULL, 4, 5.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-24 14:39:35', 0, NULL, 1, NULL, NULL, NULL),
(234, NULL, 0, 2, 1, NULL, NULL, 2, NULL, 0, 2, '2017-09-24 14:39:35', 0, NULL, 1, NULL, NULL, NULL),
(236, NULL, 0, 2, 1, NULL, NULL, 2, NULL, 0, 2, '2017-09-24 14:45:23', 0, NULL, 2, NULL, NULL, NULL),
(237, NULL, 2, 6, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-25 21:26:53', 0, NULL, 3, NULL, NULL, NULL),
(238, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-25 21:53:26', 0, NULL, 4, NULL, NULL, NULL),
(239, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-25 21:55:33', 0, NULL, 5, NULL, NULL, NULL),
(240, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-25 22:01:51', 0, NULL, 6, NULL, NULL, NULL),
(241, NULL, 2, 2, 1, NULL, NULL, 2, NULL, 0, 4, '2017-09-25 22:01:51', 0, NULL, 6, NULL, NULL, NULL),
(242, NULL, 470, 870, 0, 20, NULL, 5, NULL, 0, 9999, '2017-09-26 11:23:39', 0, NULL, NULL, NULL, NULL, NULL),
(243, NULL, 80, 180, 0, NULL, NULL, 2, NULL, 0, 9999, '2017-09-26 11:41:02', 0, NULL, NULL, NULL, 4, NULL),
(244, NULL, 0, 4, 1, NULL, NULL, 2, NULL, 0, 2, '2017-09-30 20:25:26', 0, NULL, 7, NULL, NULL, NULL),
(245, NULL, 5, 10, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-30 20:25:26', 0, NULL, 7, NULL, NULL, NULL),
(246, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 4, '2017-09-30 20:25:26', 0, NULL, 7, NULL, NULL, NULL),
(247, NULL, 0, 4, 1, NULL, NULL, 2, NULL, 0, 2, '2017-09-30 20:27:53', 0, NULL, 9, NULL, NULL, NULL),
(248, NULL, 5, 10, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-30 20:27:53', 0, NULL, 9, NULL, NULL, NULL),
(250, NULL, 13, 20, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-30 20:54:41', 0, NULL, 10, NULL, NULL, NULL),
(251, NULL, 2, 5.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-09-30 21:00:29', 0, NULL, 11, NULL, NULL, NULL),
(252, NULL, 100, 200, 0, 21, NULL, 5, NULL, 0, 9999, '2017-09-30 21:37:30', 0, NULL, NULL, NULL, NULL, NULL),
(253, NULL, 0, 70, 0, 22, NULL, 5, NULL, 0, 2, '2017-09-30 21:39:24', 0, NULL, NULL, NULL, NULL, NULL),
(254, NULL, 10, 20, 0, NULL, NULL, 5, NULL, 0, 5, '2017-09-30 22:45:06', 0, 16, NULL, NULL, NULL, NULL),
(255, NULL, 10, 20, 0, NULL, NULL, 5, NULL, 0, 4, '2017-09-30 22:45:06', 0, 16, NULL, NULL, NULL, NULL),
(256, NULL, 0, 50, 0, NULL, NULL, 5, NULL, 0, 2, '2017-09-30 22:45:06', 0, 16, NULL, NULL, NULL, NULL),
(257, NULL, 100, 200, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-30 22:45:06', 0, 16, NULL, NULL, NULL, NULL),
(258, NULL, 60, 120, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-30 22:45:56', 0, NULL, NULL, NULL, 5, NULL),
(259, NULL, 60, 120, 0, NULL, NULL, 3, NULL, 0, 9999, '2017-09-30 22:46:38', 0, NULL, NULL, NULL, 5, NULL),
(260, NULL, 20, 20, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-09-30 22:47:05', 0, NULL, NULL, NULL, 4, NULL),
(261, NULL, 0, 0, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-09-30 22:47:05', 0, NULL, NULL, NULL, 5, NULL),
(263, NULL, 5, 10, 1, NULL, NULL, 5, NULL, 0, 5, '2017-09-30 22:48:03', 0, NULL, NULL, 11, NULL, NULL),
(264, NULL, 3, 6, 0, NULL, NULL, 3, NULL, 0, 5, '2017-09-30 22:48:32', 0, NULL, NULL, 11, NULL, NULL),
(265, NULL, 2, 4, 0, NULL, NULL, 5, NULL, 0, 5, '2017-09-30 22:49:01', 0, NULL, NULL, 11, NULL, NULL),
(266, NULL, 20, 60, 1, NULL, NULL, 5, NULL, 3, 9999, '2017-09-30 22:49:41', 0, NULL, NULL, NULL, NULL, NULL),
(267, NULL, 10, 20, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-09-30 22:53:21', 0, NULL, NULL, NULL, NULL, 3),
(268, NULL, 5, 10, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-09-30 22:55:51', 0, NULL, NULL, NULL, NULL, 3),
(269, NULL, 5, 10, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-01 00:16:53', 0, NULL, NULL, NULL, NULL, 4),
(270, NULL, 0, 5, 1, NULL, NULL, 5, NULL, 0, 2, '2017-10-01 00:16:53', 0, NULL, NULL, NULL, NULL, 4),
(272, NULL, 1, 2, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-10-01 00:17:45', 0, NULL, NULL, NULL, NULL, 4),
(273, NULL, 0, 0, 0, NULL, NULL, 5, NULL, 0, 2, '2017-10-01 00:17:45', 0, NULL, NULL, NULL, NULL, 4),
(275, NULL, 200, 400, 0, 23, NULL, 5, NULL, 0, 9999, '2017-10-01 01:43:43', 0, NULL, NULL, NULL, NULL, NULL),
(276, NULL, 120, 200, 0, 24, NULL, 5, NULL, 0, 9999, '2017-10-01 21:44:34', 0, NULL, NULL, NULL, NULL, NULL),
(277, NULL, 20, 40, 0, NULL, NULL, 5, NULL, 0, 4, '2017-10-01 21:47:16', 0, 17, NULL, NULL, NULL, NULL),
(278, NULL, 20, 40, 0, NULL, NULL, 5, NULL, 0, 5, '2017-10-01 21:47:16', 0, 17, NULL, NULL, NULL, NULL),
(279, NULL, 0, 20, 0, NULL, NULL, 5, NULL, 0, 2, '2017-10-01 21:47:16', 0, 17, NULL, NULL, NULL, NULL),
(280, NULL, 211, 182, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-01 21:47:16', 0, 17, NULL, NULL, NULL, NULL),
(281, NULL, 100, 200, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-01 21:48:21', 0, NULL, NULL, NULL, 6, NULL),
(282, NULL, 100, 200, 0, NULL, NULL, 3, NULL, 0, 9999, '2017-10-01 21:51:56', 0, NULL, NULL, NULL, 6, NULL),
(283, NULL, 0, 0, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-10-01 21:53:12', 0, NULL, NULL, NULL, 6, NULL),
(284, NULL, 30, 50, 1, NULL, NULL, 5, NULL, 0, 4, '2017-10-01 22:03:27', 0, NULL, NULL, 12, NULL, NULL),
(285, NULL, 30, 50, 0, NULL, NULL, 3, NULL, 0, 4, '2017-10-01 22:05:22', 0, NULL, NULL, 12, NULL, NULL),
(286, NULL, 0, 0, 0, NULL, NULL, 5, NULL, 0, 4, '2017-10-01 22:07:30', 0, NULL, NULL, 12, NULL, NULL),
(287, NULL, 5, 10, 1, NULL, NULL, 5, NULL, 4, 9999, '2017-10-01 22:09:49', 0, NULL, NULL, NULL, NULL, NULL),
(288, NULL, 0, 5, 1, NULL, NULL, 5, NULL, 0, 2, '2017-10-01 22:11:16', 0, NULL, NULL, NULL, NULL, 5),
(289, NULL, 0, 2, 0, NULL, NULL, 5, NULL, 0, 2, '2017-10-01 22:19:23', 0, NULL, NULL, NULL, NULL, 5),
(291, NULL, 60, 120, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-03 12:16:53', 0, NULL, NULL, NULL, 8, NULL),
(292, NULL, 60, 120, 1, NULL, NULL, 3, NULL, 0, 9999, '2017-10-03 12:17:36', 0, NULL, NULL, NULL, 9, NULL),
(293, NULL, 60, 120, 0, NULL, NULL, 1, NULL, 0, 9999, '2017-10-03 12:22:51', 0, NULL, NULL, NULL, 9, NULL),
(294, NULL, 0, 0, 0, NULL, NULL, 3, NULL, 0, 9999, '2017-10-03 12:23:45', 0, NULL, NULL, NULL, 9, NULL),
(295, NULL, 23, 41, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-03 12:25:26', 0, NULL, NULL, NULL, 10, NULL),
(296, NULL, 13, 31, 0, NULL, NULL, 1, NULL, 0, 9999, '2017-10-03 12:26:03', 0, NULL, NULL, NULL, 10, NULL),
(297, NULL, 10, 10, 0, NULL, NULL, 2, NULL, 0, 9999, '2017-10-03 12:29:20', 0, NULL, NULL, NULL, 10, NULL),
(298, NULL, 35, 70, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-03 12:33:10', 0, NULL, NULL, NULL, 11, NULL),
(299, NULL, 35, 70, 0, NULL, NULL, 2, NULL, 0, 9999, '2017-10-03 12:34:00', 0, NULL, NULL, NULL, 11, NULL),
(300, NULL, 0, 0, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-10-03 12:34:15', 0, NULL, NULL, NULL, 11, NULL),
(301, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-04 12:24:18', 0, NULL, 12, NULL, NULL, NULL),
(302, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-04 12:24:32', 0, NULL, 13, NULL, NULL, NULL),
(303, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-04 12:25:27', 0, NULL, 14, NULL, NULL, NULL),
(304, NULL, 2, 4, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-04 12:26:28', 0, NULL, 15, NULL, NULL, NULL),
(305, NULL, 1, 2, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-05 19:47:00', 0, NULL, 16, NULL, NULL, NULL),
(306, NULL, 1, 2, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-05 19:47:19', 0, NULL, 17, NULL, NULL, NULL),
(307, NULL, 1, 2, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-05 19:48:38', 0, NULL, 18, NULL, NULL, NULL),
(308, NULL, 1, 2, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-05 19:48:50', 0, NULL, 19, NULL, NULL, NULL),
(309, NULL, 50, 100, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-05 20:19:49', 0, NULL, NULL, NULL, 12, NULL),
(310, NULL, 40, 80, 0, NULL, NULL, 2, NULL, 0, 9999, '2017-10-05 20:20:47', 0, NULL, NULL, NULL, 12, NULL),
(311, NULL, 10, 20, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-10-05 20:21:18', 0, NULL, NULL, NULL, 12, NULL),
(312, NULL, 10, 20, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-05 20:21:38', 0, NULL, NULL, NULL, 13, NULL),
(313, NULL, 10, 20, 0, NULL, NULL, 2, NULL, 0, 9999, '2017-10-05 20:22:03', 0, NULL, NULL, NULL, 13, NULL),
(314, NULL, 10, 20, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-05 20:22:12', 0, NULL, NULL, NULL, 13, NULL),
(315, NULL, 0, 12, 1, NULL, NULL, 5, NULL, 0, 2, '2017-10-05 20:22:52', 0, NULL, NULL, 13, NULL, NULL),
(316, NULL, 10, 20, 1, NULL, NULL, 5, NULL, 0, 4, '2017-10-05 20:22:52', 0, NULL, NULL, 13, NULL, NULL),
(318, NULL, 0, 6, 0, NULL, NULL, 2, NULL, 0, 2, '2017-10-05 20:23:30', 0, NULL, NULL, 13, NULL, NULL),
(319, NULL, 5, 10, 0, NULL, NULL, 2, NULL, 0, 4, '2017-10-05 20:23:30', 0, NULL, NULL, 13, NULL, NULL),
(321, NULL, 0, 6, 0, NULL, NULL, 5, NULL, 0, 2, '2017-10-05 20:23:57', 0, NULL, NULL, 13, NULL, NULL),
(322, NULL, 5, 10, 0, NULL, NULL, 5, NULL, 0, 4, '2017-10-05 20:23:57', 0, NULL, NULL, 13, NULL, NULL),
(324, NULL, 0, 3, 1, NULL, NULL, 5, NULL, 0, 2, '2017-10-05 20:24:42', 0, NULL, NULL, 14, NULL, NULL),
(325, NULL, 3, 5, 1, NULL, NULL, 5, NULL, 0, 4, '2017-10-05 20:24:42', 0, NULL, NULL, 14, NULL, NULL),
(327, NULL, 0, 3, 0, NULL, NULL, 2, NULL, 0, 2, '2017-10-05 20:25:20', 0, NULL, NULL, 14, NULL, NULL),
(328, NULL, 3, 5, 0, NULL, NULL, 2, NULL, 0, 4, '2017-10-05 20:25:20', 0, NULL, NULL, 14, NULL, NULL),
(330, NULL, 0, 3, 1, NULL, NULL, 5, NULL, 0, 2, '2017-10-05 20:30:17', 0, NULL, NULL, 15, NULL, NULL),
(331, NULL, 2, 4, 1, NULL, NULL, 5, NULL, 0, 4, '2017-10-05 20:30:17', 0, NULL, NULL, 15, NULL, NULL),
(333, NULL, 0, 3, 0, NULL, NULL, 2, NULL, 0, 2, '2017-10-05 20:32:12', 0, NULL, NULL, 15, NULL, NULL),
(334, NULL, 2, 4, 0, NULL, NULL, 2, NULL, 0, 4, '2017-10-05 20:32:12', 0, NULL, NULL, 15, NULL, NULL),
(336, NULL, 0, 3, 1, NULL, NULL, 5, NULL, 0, 2, '2017-10-05 20:39:58', 0, NULL, NULL, 15, NULL, NULL),
(337, NULL, 3, 6, 1, NULL, NULL, 5, NULL, 0, 4, '2017-10-05 20:39:58', 0, NULL, NULL, 15, NULL, NULL),
(339, NULL, 5, 10, 1, NULL, NULL, 5, NULL, 0, 9999, '2017-10-05 20:48:51', 0, NULL, NULL, NULL, NULL, 6),
(340, NULL, 1, 2, 0, NULL, NULL, 5, NULL, 0, 9999, '2017-10-05 20:49:08', 0, NULL, NULL, NULL, NULL, 6),
(341, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:46:55', 0, NULL, 20, NULL, NULL, NULL),
(342, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:48:06', 0, NULL, 21, NULL, NULL, NULL),
(343, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:49:32', 0, NULL, 22, NULL, NULL, NULL),
(344, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:50:18', 0, NULL, 23, NULL, NULL, NULL),
(345, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:50:39', 0, NULL, 24, NULL, NULL, NULL),
(346, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:52:49', 0, NULL, 25, NULL, NULL, NULL),
(347, NULL, 1, 1.5, 1, NULL, NULL, 2, NULL, 0, 9999, '2017-10-07 11:54:13', 0, NULL, 26, NULL, NULL, NULL),
(348, NULL, 1, 0.2652, 1, NULL, NULL, 2, NULL, 0, 4, '2017-10-09 14:46:00', 0, NULL, 27, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `stock_view`
--
DROP VIEW IF EXISTS `stock_view`;
CREATE TABLE IF NOT EXISTS `stock_view` (
`stock_id` int(11)
,`type` int(11)
,`qty` float
,`weight` float
,`st_inout` int(11)
,`pur_id` int(11)
,`st_total` float
,`shop_id` int(11)
,`wt_total` float
,`loss_id` int(11)
,`prod_id` bigint(20)
,`st_date` datetime
,`st_status` int(11)
,`pro_id` bigint(20)
,`sales_id` bigint(20)
,`ppr_id` bigint(20)
,`tr_id` bigint(20)
);

-- --------------------------------------------------------

--
-- Table structure for table `sub_menu`
--

DROP TABLE IF EXISTS `sub_menu`;
CREATE TABLE IF NOT EXISTS `sub_menu` (
  `sub_menu_id` int(11) NOT NULL AUTO_INCREMENT,
  `main_menu_id` int(11) NOT NULL,
  `sub_menu_page_name` varchar(50) DEFAULT NULL,
  `sub_menu_page_title` varchar(50) DEFAULT NULL,
  `sub_menu_order` int(11) DEFAULT NULL,
  `shown_status` int(11) DEFAULT NULL,
  `sub_menu_allow` int(11) DEFAULT NULL,
  PRIMARY KEY (`sub_menu_id`),
  KEY `FK_sub_menu_main_menu` (`main_menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sub_menu`
--

INSERT INTO `sub_menu` (`sub_menu_id`, `main_menu_id`, `sub_menu_page_name`, `sub_menu_page_title`, `sub_menu_order`, `shown_status`, `sub_menu_allow`) VALUES
(1, 2, 'product.php', 'Products', NULL, 0, NULL),
(2, 2, 'product_cat.php', 'Product Category', NULL, 0, NULL),
(3, 4, 'rates.php', 'Products Rate', NULL, 0, NULL),
(4, 4, 'daily_rates.php', 'Live Chicken Rate', NULL, 0, NULL),
(5, 6, 'prod_processed.php', 'Chiller Processed (Transfer)', NULL, 0, NULL),
(6, 6, 'prod_dispatch.php', 'Chiller Dispatch (Return & Loss)', NULL, 0, NULL),
(7, 7, 'live_transfer.php', 'Transfer', NULL, 0, NULL),
(8, 7, 'live_mng.php', 'Manage (Return & Loss)', NULL, 0, NULL),
(9, 10, 'cust.php', 'Customers Management', NULL, 0, NULL),
(10, 10, 'cust_factor.php', 'Customer Factor', NULL, 0, NULL),
(11, 10, 'cust_order.php', 'Customers Order', NULL, 0, NULL),
(12, 10, 'cust_payment.php', 'Customers Payment', NULL, 0, NULL),
(13, 11, 'ie_cat.php', 'I/E Category', NULL, 0, NULL),
(14, 11, 'ie_cat_detail.php', 'I/E Detail', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sub_menu_allow`
--

DROP TABLE IF EXISTS `sub_menu_allow`;
CREATE TABLE IF NOT EXISTS `sub_menu_allow` (
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `main_menu_id` int(11) NOT NULL,
  `sub_menu_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`row_id`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `sub_menu_allow`
--

INSERT INTO `sub_menu_allow` (`row_id`, `main_menu_id`, `sub_menu_id`, `user_id`) VALUES
(60, 6, 5, 14),
(61, 6, 6, 14),
(62, 7, 7, 14),
(63, 7, 8, 14),
(64, 10, 9, 14),
(65, 10, 10, 14),
(66, 10, 11, 14),
(67, 10, 12, 14),
(78, 2, 1, 4),
(79, 2, 2, 4),
(80, 4, 3, 4),
(81, 4, 4, 4),
(82, 6, 5, 4),
(83, 6, 6, 4),
(84, 7, 7, 4),
(85, 7, 8, 4),
(86, 10, 9, 4),
(87, 10, 10, 4),
(88, 10, 11, 4),
(89, 10, 12, 4),
(90, 2, 1, 12),
(91, 2, 2, 12),
(92, 4, 3, 12),
(93, 4, 4, 12),
(94, 6, 5, 12),
(95, 6, 6, 12),
(96, 7, 7, 12),
(97, 10, 9, 12),
(98, 10, 10, 12),
(99, 10, 11, 12),
(100, 10, 12, 12),
(101, 11, 13, 12),
(102, 11, 14, 12);

-- --------------------------------------------------------

--
-- Table structure for table `test`
--

DROP TABLE IF EXISTS `test`;
CREATE TABLE IF NOT EXISTS `test` (
  `col1` text,
  `col2` text,
  `col3` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `test`
--

INSERT INTO `test` (`col1`, `col2`, `col3`) VALUES
('3', 'abc', 'address'),
('2', 'Commercial', 'Commercial Market'),
('1', 'tesy', 'asdd');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(15) NOT NULL,
  `password` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `shop_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `username`, `password`, `name`, `status`, `shop_id`) VALUES
(4, 'user', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'Waleed Ahmed', 0, 2),
(6, 'admin', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'IC ADMIN', 0, 5),
(7, 'waleed', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'Waleed Waheed', 0, 2),
(9, 'test', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'test name', 0, 1),
(10, 'testu', 'a1Bz20ydqelm8m1wql827ccb0eea8a706c4c34a16891f84e7b', 'test namez', 0, 2),
(12, 'wal', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'Waleed Waheed', 0, 2),
(13, 'wal', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'waa', 0, 5),
(14, 'wal', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'wal', 0, 3),
(15, 'wals', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'Waleed Waheed', 0, 5),
(16, 'ahmi', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'Waleed Waheed', 0, 6),
(17, 'ahmed', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'adsd', 0, 1),
(18, 'rehan', 'a1Bz20ydqelm8m1wql202cb962ac59075b964b07152d234b70', 'Rehan', 0, 5);

-- --------------------------------------------------------

--
-- Structure for view `live_transfer_view`
--
DROP TABLE IF EXISTS `live_transfer_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `live_transfer_view`  AS  select `t`.`tr_id` AS `tr_id`,`t`.`s_qty` AS `s_qty`,`t`.`s_weight` AS `s_weight`,`t`.`r_qty` AS `r_qty`,`t`.`r_weight` AS `r_weight`,`t`.`shop_id` AS `shop_id`,`t`.`s_shop_id` AS `s_shop_id`,`t`.`tr_datetime` AS `tr_datetime`,`t`.`tr_status` AS `tr_status`,`t`.`rcv_datetime` AS `rcv_datetime` from `live_transfer` `t` order by `t`.`tr_id` desc WITH CASCADED CHECK OPTION ;

-- --------------------------------------------------------

--
-- Structure for view `production_view`
--
DROP TABLE IF EXISTS `production_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `production_view`  AS  select `p`.`pro_id` AS `pro_id`,`p`.`pro_date` AS `pro_date`,`p`.`daily_rate` AS `daily_rate`,`p`.`pr_qty` AS `pr_qty`,`p`.`pr_weight` AS `pr_weight`,`p`.`pro_status` AS `pro_status`,`p`.`shop_id` AS `shop_id`,`p`.`pro_datetime` AS `pro_datetime` from `production` `p` order by `p`.`pro_id` desc WITH CASCADED CHECK OPTION ;

-- --------------------------------------------------------

--
-- Structure for view `prod_processed_view`
--
DROP TABLE IF EXISTS `prod_processed_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `prod_processed_view`  AS  select `pp`.`ppr_id` AS `ppr_id`,`pp`.`shop_id` AS `shop_id`,`pp`.`ppr_date` AS `ppr_date`,`pp`.`ppr_status` AS `ppr_status`,`pp`.`s_shop_id` AS `s_shop_id`,`pp`.`ppr_datetime` AS `ppr_datetime` from `prod_processed` `pp` order by `pp`.`ppr_id` desc WITH CASCADED CHECK OPTION ;

-- --------------------------------------------------------

--
-- Structure for view `purchase_view`
--
DROP TABLE IF EXISTS `purchase_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `purchase_view`  AS  select `p`.`pur_id` AS `pur_id`,`p`.`pur_from` AS `pur_from`,`p`.`party_name` AS `party_name`,`p`.`party_rate` AS `party_rate`,`p`.`mandi_rate` AS `mandi_rate`,`p`.`pur_date` AS `pur_date`,`p`.`shop_id` AS `shop_id`,`p`.`qty` AS `qty`,`p`.`weight` AS `weight`,`p`.`driver` AS `driver`,`p`.`vehicle` AS `vehicle`,`p`.`location` AS `location`,`p`.`weight_loss` AS `weight_loss`,`p`.`qty_loss` AS `qty_loss`,`p`.`bird_wgt_loss` AS `bird_wgt_loss`,`p`.`p_status` AS `p_status`,`p`.`prod_id` AS `prod_id` from `purchase` `p` order by `p`.`pur_id` desc WITH CASCADED CHECK OPTION ;

-- --------------------------------------------------------

--
-- Structure for view `stock_view`
--
DROP TABLE IF EXISTS `stock_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `stock_view`  AS  select `s`.`stock_id` AS `stock_id`,`s`.`type` AS `type`,`s`.`qty` AS `qty`,`s`.`weight` AS `weight`,`s`.`st_inout` AS `st_inout`,`s`.`pur_id` AS `pur_id`,`s`.`st_total` AS `st_total`,`s`.`shop_id` AS `shop_id`,`s`.`wt_total` AS `wt_total`,`s`.`loss_id` AS `loss_id`,`s`.`prod_id` AS `prod_id`,`s`.`st_date` AS `st_date`,`s`.`st_status` AS `st_status`,`s`.`pro_id` AS `pro_id`,`s`.`sales_id` AS `sales_id`,`s`.`ppr_id` AS `ppr_id`,`s`.`tr_id` AS `tr_id` from `stock` `s` order by `s`.`stock_id` desc WITH CASCADED CHECK OPTION ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `barcode`
--
ALTER TABLE `barcode`
  ADD CONSTRAINT `FK_barcode_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `cust_factor`
--
ALTER TABLE `cust_factor`
  ADD CONSTRAINT `FK_cust_factor_customer` FOREIGN KEY (`cust_id`) REFERENCES `customer` (`cust_id`) ON UPDATE CASCADE;

--
-- Constraints for table `cust_order`
--
ALTER TABLE `cust_order`
  ADD CONSTRAINT `FK_cust_order_customer` FOREIGN KEY (`cust_id`) REFERENCES `customer` (`cust_id`);

--
-- Constraints for table `cust_order_amount`
--
ALTER TABLE `cust_order_amount`
  ADD CONSTRAINT `FK_cust_order_amount_cust_order` FOREIGN KEY (`co_id`) REFERENCES `cust_order` (`co_id`);

--
-- Constraints for table `cust_order_detail`
--
ALTER TABLE `cust_order_detail`
  ADD CONSTRAINT `FK_cust_order_detail_cust_order` FOREIGN KEY (`co_id`) REFERENCES `cust_order` (`co_id`);

--
-- Constraints for table `ie_detail`
--
ALTER TABLE `ie_detail`
  ADD CONSTRAINT `FK_ie_detail_ie_cat` FOREIGN KEY (`iecat_id`) REFERENCES `ie_cat` (`iecat_id`);

--
-- Constraints for table `loss`
--
ALTER TABLE `loss`
  ADD CONSTRAINT `purid_loss` FOREIGN KEY (`pur_id`) REFERENCES `purchase` (`pur_id`);

--
-- Constraints for table `ppr_products`
--
ALTER TABLE `ppr_products`
  ADD CONSTRAINT `FK1_ppr` FOREIGN KEY (`ppr_id`) REFERENCES `prod_processed` (`ppr_id`) ON UPDATE CASCADE;

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `FK_product_product_category` FOREIGN KEY (`pcat_id`) REFERENCES `product_category` (`pcat_id`);

--
-- Constraints for table `production_batches`
--
ALTER TABLE `production_batches`
  ADD CONSTRAINT `FK_production_batches_production` FOREIGN KEY (`pro_id`) REFERENCES `production` (`pro_id`) ON UPDATE CASCADE;

--
-- Constraints for table `production_prod`
--
ALTER TABLE `production_prod`
  ADD CONSTRAINT `FK_production_prod_production` FOREIGN KEY (`pro_id`) REFERENCES `production` (`pro_id`) ON UPDATE CASCADE;

--
-- Constraints for table `purchase`
--
ALTER TABLE `purchase`
  ADD CONSTRAINT `shopid_purchase` FOREIGN KEY (`shop_id`) REFERENCES `shop` (`shop_id`);

--
-- Constraints for table `rates`
--
ALTER TABLE `rates`
  ADD CONSTRAINT `prod_rates` FOREIGN KEY (`prod_id`) REFERENCES `product` (`prod_id`),
  ADD CONSTRAINT `shopid_rates` FOREIGN KEY (`shop_id`) REFERENCES `shop` (`shop_id`);

--
-- Constraints for table `sales`
--
ALTER TABLE `sales`
  ADD CONSTRAINT `itemtype_sales` FOREIGN KEY (`item_type`) REFERENCES `item_type` (`it_id`),
  ADD CONSTRAINT `shopid_sales` FOREIGN KEY (`shop_id`) REFERENCES `shop` (`shop_id`);

--
-- Constraints for table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `pur_stock` FOREIGN KEY (`pur_id`) REFERENCES `purchase` (`pur_id`);

--
-- Constraints for table `sub_menu`
--
ALTER TABLE `sub_menu`
  ADD CONSTRAINT `FK_sub_menu_main_menu` FOREIGN KEY (`main_menu_id`) REFERENCES `main_menu` (`main_menu_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
