package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：KN_LSN_001 【学生授業情報管理】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_lessonPK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;
    @Column  private String lessonId;
    @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            TInfo_lessonPK modelKey = (TInfo_lessonPK ) o;
            return  Objects.equals(lessonId, modelKey.lessonId) ;
        }
        @Override
        public int hashCode() {
            return Objects.hash(lessonId);
        }
}
