package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：KN_FIXf_LSN_001 【固定授業計画管理】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_fixedlessonPK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;

    @Column  private String stuId;
    @Column  private String subjectId;
    @Column  private String fixedWeek;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TInfo_fixedlessonPK modelKey = (TInfo_fixedlessonPK ) o;
        return  Objects.equals(stuId, modelKey.stuId)  &&  Objects.equals(subjectId, modelKey.subjectId) &&  Objects.equals(fixedWeek, modelKey.fixedWeek);
    }
    @Override
    public int hashCode() {
        return Objects.hash(stuId ,subjectId ,fixedWeek);
    }
}