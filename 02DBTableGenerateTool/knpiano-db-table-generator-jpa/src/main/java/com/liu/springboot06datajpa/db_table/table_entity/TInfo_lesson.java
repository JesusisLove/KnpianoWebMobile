package com.liu.springboot06datajpa.db_table.table_entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.liu.springboot06datajpa.db_table.primarykeys.TInfo_lessonPK;
import lombok.Data;

import javax.persistence.*;
import java.sql.Timestamp;
import java.util.Date;

/* 機能番号：KN_BNK_001 【学科基本情報マスタ】テーブルを生成する */
@SuppressWarnings("JpaDataSourceORMInspection")
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
// 👇テーブル名称はあってるかどうかを確認注意"
@Table(name = "t_info_lesson")
// 👇PKのクラス名称はあってるかどうかを確認注意
@IdClass(value = TInfo_lessonPK.class)
public class TInfo_lesson {
    @Id @Column (name = "lesson_id", length = 32, nullable = false)  protected String lessonId;
    @Column (name = "subject_id", length = 32)  protected String subjectId;
    @Column (name = "stu_id", length = 32)  protected String stuId;
    @Column (name = "subject_sub_id", length = 32)  protected String subjectSubId;
    @Column (name = "class_duration")  protected Date classDuration;
    @Column (name = "lesson_type")  protected Integer lessonType;
    @Column (name = "schedual_type")  protected Integer schedualType;
    @Column (name = "schedual_date")  protected Date schedualDate;
    @Column (name = "scanQR_date")  protected Date scanQRDate;
    @Column (name = "lsn_adjusted_date")  protected Date lsnAdjustedDate;
    @Column (name = "extra_to_dur_date")  protected Date extraToDurDate;
    @Column (name = "del_flg", columnDefinition = "integer default 0")  protected Integer delFlg;
    @Column (name = "create_date", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")  protected Timestamp createDate;
    @Column (name = "update_date", columnDefinition = "TIMESTAMP DEFAULT NULL")  protected Timestamp updateDate;
}