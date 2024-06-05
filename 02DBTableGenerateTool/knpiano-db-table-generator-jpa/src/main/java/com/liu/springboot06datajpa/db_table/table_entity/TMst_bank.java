package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TMst_bankPK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
// import java.util.Date;

/* 機能番号：KN_BNK_001 【学科基本情報マスタ】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_mst_bank")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TMst_bankPK.class)
public class TMst_bank {

    @Id
    @Column (name = "bank_id", length = 32, nullable = false)  
    protected String bankId;

    @Column (name = "bank_name", length = 20, nullable = false)  
    protected String bankName;

    @Column(name = "del_flg", columnDefinition = "integer default 0")
    protected Integer delFlg;

    @Column (name = "create_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  
    protected Timestamp createDate;
    
    @Column (name = "update_date", columnDefinition = "TIMESTAMP DEFAULT NULL")  
    protected Timestamp updateDate;
}