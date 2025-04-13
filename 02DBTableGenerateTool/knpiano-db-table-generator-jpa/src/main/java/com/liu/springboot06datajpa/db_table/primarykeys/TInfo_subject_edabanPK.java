package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;

/* 機能番号：KN_05S002_SUBJECT_EDABN 【科目枝番管理設定】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_subject_edabanPK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;

    @Column  private String subjectSubId;
    @Column  private String subjectId;


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TInfo_subject_edabanPK modelKey = (TInfo_subject_edabanPK ) o;
        return  Objects.equals(subjectSubId, modelKey.subjectSubId)  &&  Objects.equals(subjectId, modelKey.subjectId);
    }
    @Override
    public int hashCode() {
        return Objects.hash(subjectSubId ,subjectId);
    }
}