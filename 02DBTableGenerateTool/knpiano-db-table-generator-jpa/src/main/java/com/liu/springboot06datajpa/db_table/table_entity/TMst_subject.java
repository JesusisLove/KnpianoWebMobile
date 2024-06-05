package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TMst_subjectPK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
// import java.util.Date;

/* 機能番号：KN_SUB_001 【学科基本情報マスタ】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_mst_subject")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TMst_subjectPK.class)
public class TMst_subject {

    @Id @Column (name = "subject_id", length = 32, nullable = false)  protected String subjectId;
    @Id @Column (name = "subject_sub_id", length = 32, nullable = false)  protected String subjectSubId;
    @Column (name = "subject_name", length = 20)  protected String subjectName;
    @Column (name = "subject_sub_name", length = 20)  protected String subjectSubName;
    @Column (name = "subject_price", columnDefinition = "TIMESTAMP  default CURRENT_TIMESTAMP")  protected float subjectPrice;
    @Column (name = "del_flg", columnDefinition = "integer  default NULL")  protected Integer delFlg;
    @Column (name = "create_date")  protected Timestamp createDate;
    @Column (name = "update_date")  protected Timestamp updateDate;
}
