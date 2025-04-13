package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import java.util.List;

@Mapper
public interface Kn05S002WeekCalculatorMapper {
    public List<Kn05S002FixedLsnStatusBean> getInfoList();

    public List<Kn05S002FixedLsnStatusBean> getInfoList4mb();

    void insertFixedLessonStatus(Kn05S002FixedLsnStatusBean status);
    
    public void deleteAll();
    
    // 执行一周计划排课的Batch处理
    public void doLsnWeeklySchedual(@Param("weekStart")String weekStart, 
                                    @Param("weekEnd")String weekEnd, 
                                    @Param("SEQCode")String SEQCode);

    // 更新周次排课表里的排课状态
    public void updateWeeklyBatchStatus(@Param("weekStart")String weekStart, 
                                        @Param("weekEnd")String weekEnd,
                                        @Param("lsnStatus")Integer lsnStatus
                                        );

    // 撤销一周的排课
    public void cancelWeeklySchedual(@Param("weekStart")String weekStart, 
                                     @Param("weekEnd")String weekEnd);
    
    // 看看排的一周的课里有没有签到的课，只要有一个签到就不可撤销 
    public List<Kn01L002LsnBean> checkLsnHasSignedOrNot (@Param("weekStart")String weekStart, 
                                                         @Param("weekEnd")String weekEnd);
}