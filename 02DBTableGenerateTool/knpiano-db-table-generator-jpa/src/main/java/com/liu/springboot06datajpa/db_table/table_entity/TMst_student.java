package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TMst_studentPK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
// import java.util.Date;

/* 機能番号：KN_STU_001 【学生基本情報マスタ】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_mst_student")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TMst_studentPK.class)
public class TMst_student {

    @Id 
    @Column (name = "stu_id", length = 32, nullable = false)  
    protected String stuId;

    @Column (name = "stu_name", length = 20, nullable = false)  
    protected String stuName;

    @Column (name = "gender") 
     protected Integer gender;

    @Column (name = "birthday", length = 10)  
    protected String birthday;

    @Column (name = "tel1", length = 20)  
    protected String tel1;

    @Column (name = "tel2", length = 20)  
    protected String tel2;

    @Column (name = "tel3", length = 20)  
    protected String tel3;

    @Column (name = "tel4", length = 20)  
    protected String tel4;

    @Column (name = "address", length = 64)  
    protected String address;

    @Column (name = "post_code", length = 12)  
    protected String postCode;

    @Column (name = "introducer", length = 20)  
    protected String introducer;
    
    @Column (name = "del_flg")  
    protected Integer delFlg;

    @Column (name = "create_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  
    protected Timestamp createDate;
    
    @Column (name = "update_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  
    protected Timestamp updateDate;
}
