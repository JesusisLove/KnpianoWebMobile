package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_subject_edabanPK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;

/* 機能番号：KN_05S002_SUBJECT_EDABN 【科目枝番管理設定】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_subject_edaban")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_subject_edabanPK.class)
public class TInfo_subject_edaban {

    @Id @Column (name = "subject_sub_id", length = 32, nullable = false)  protected String subjectSubId;
    @Id @Column (name = "subject_id", length = 32, nullable = false)  protected String subjectId;
    @Column (name = "subject_sub_name", length = 20)  protected String subjectSubName;
    @Column (name = "subject_price")  protected float subjectPrice;
    @Column (name = "del_flg", columnDefinition = "integer default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP DEFAULT NULL")  protected Timestamp updateDate;

}
