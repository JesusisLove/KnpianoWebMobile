package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：KN_LSN_FEE_001 【課費情報管理】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_lesson_feePK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;

    @Column  private String lsnFeeId;
    @Column  private String lessonId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TInfo_lesson_feePK modelKey = (TInfo_lesson_feePK ) o;
        return  Objects.equals(lsnFeeId, modelKey.lsnFeeId)  &&  Objects.equals(lessonId, modelKey.lessonId);
    }
    @Override
    public int hashCode() {
        return Objects.hash(lsnFeeId ,lessonId);
    }
}