package com.beefe.picker.view;

import android.content.Context;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;

import java.util.ArrayList;
import java.util.List;

/**
 * 可N级联动的时间控件
 */
public class NewPickerViewLinkage extends LinearLayout {

    private OnSelectedListener onSelectedListener;
    private LinearLayout lineLayout;
    private ReadableArray data = null;
    private ArrayList<ReturnData> curSelectedList;
    /**
     * 时间控件高度
     */
    private int height;
    /**
     * 列数
     */
    private int depth = 1;
    /**
     * 装所有的LoopView的容器
     */
    private List<LoopView> loopViewArr = new ArrayList<LoopView>();

    public NewPickerViewLinkage(Context context) {
        super(context);
        init(context);
    }

    /**
     * 初始化一个水平布局
     * @param context
     */
    private void init(Context context) {
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        lineLayout = new LinearLayout(context);
        lineLayout.setOrientation(LinearLayout.HORIZONTAL);
        lineLayout.setLayoutParams(params);
    }

    /**
     * 设置LoopView中内容
     * @param loopView
     * @param list
     */
    private void checkItems(LoopView loopView, ArrayList<String> list) {
        if (list != null && list.size() > 0) {
            loopView.setItems(list);
            loopView.setSelectedPosition(0);
        }
    }

    /**
     * 根据传入数组数据，往lineLayout添加LoopView，并为LoopView添加监听
     * @param array
     * @param weights
     * @param context
     * @param pickerLayout
     */
    public void setPickerData(ReadableArray array, double[] weights,Context context,RelativeLayout pickerLayout) {
        this.data=array;
        curSelectedList = new ArrayList<>();
        ReadableMap map0 = array.getMap(0);
        while(map0.keySetIterator().hasNextKey()){
            depth++;
            ReadableArray arr = map0.getArray(map0.keySetIterator().nextKey());
            if(arr.getType(0).name().equals("Map"))
                map0=arr.getMap(0);
            else
                break;
        }
        for(int i=0;i<depth;i++) {
            final int curRow=i;
            LoopView loopView = new LoopView(context);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(0,
                    LinearLayout.LayoutParams.MATCH_PARENT);
            if (weights != null) {
                layoutParams.weight = (float)weights[i];
            }
            else {
                layoutParams.weight = 1.0f;
            }
            loopView.setLayoutParams(layoutParams);
            ArrayList<String> list = getData(array);
            checkItems(loopView, list);

            ReturnData returnData = new ReturnData();
            returnData.setItem(list.get(0));
            returnData.setIndex(loopView.getSelectedIndex());
            if (curSelectedList.size() > i) {
                curSelectedList.set(i, returnData);
            } else {
                curSelectedList.add(i, returnData);
            }

            if(array.getType(0).name().equals("Map")){
                ReadableMap map = array.getMap(0);
                ReadableMapKeySetIterator iterator = map.keySetIterator();
                if (iterator.hasNextKey()) {
                    String value = iterator.nextKey();
                    array=map.getArray(value);
                }
            }
            lineLayout.addView(loopView);
            height=loopView.getViewHeight();
            loopViewArr.add(loopView);
            loopView.setListener(new OnItemSelectedListener() {
                @Override
                public void onItemSelected(String item, int index) {
                    ReturnData returnData = new ReturnData();
                    returnData.setItem(item);
                    returnData.setIndex(index);
                    curSelectedList.set(curRow, returnData);
                    setData(curRow);
                    if (onSelectedListener != null) {
                        onSelectedListener.onSelected(curSelectedList);
                    }
                }

            });

        }
        pickerLayout.addView(lineLayout);
    }

    /**
     * 把传入的array转换成ArrayList<String>，便于数据填充
     * @param array
     * @return
     */
    private ArrayList<String> getData(ReadableArray array){
         ArrayList<String> list = new ArrayList<>();
         list.clear();
         if(array.getType(0).name().equals("Map"))
            for (int m = 0; m < array.size(); m++) {
                ReadableMap map = array.getMap(m);
                ReadableMapKeySetIterator iterator = map.keySetIterator();
                if (iterator.hasNextKey()) {
                    String value = iterator.nextKey();
                    list.add(value);
                }
            }
          else
             list = arrayToList(array);

         return list;
    }

    /**
     * 滚动时设置每个LoopView中的数据和位置
     * @param curRow
     */
    private void setData(int curRow){
        ReadableArray curArray =data;
        for(int i=0;i<=curRow;i++){
            if(curArray.getType(0).name().equals("Map")){
                ReadableMap map = curArray.getMap(loopViewArr.get(i).getSelectedIndex());
                ReadableMapKeySetIterator iterator = map.keySetIterator();
                if (iterator.hasNextKey()) {
                    String value = iterator.nextKey();
                    curArray=map.getArray(value);
                }
            }
        }

        for(int j=curRow+1;j<depth;j++){
            ArrayList<String> list = getData(curArray);
            loopViewArr.get(j).setItems(list);
            loopViewArr.get(j).setSelectedPosition(0);
            if(curArray.getType(0).name().equals("Map")){
                ReadableMap map = curArray.getMap(0);
                ReadableMapKeySetIterator iterator = map.keySetIterator();
                if (iterator.hasNextKey()) {
                    String value = iterator.nextKey();
                    curArray=map.getArray(value);
                }
            }
        }

    }

    private ArrayList<String> arrayToList(ReadableArray array) {
        try {
            ArrayList<String> list = new ArrayList<>();
            for (int i = 0; i < array.size(); i++) {
                String values = "";
                switch (array.getType(i).name()) {
                    case "Boolean":
                        values = String.valueOf(array.getBoolean(i));
                        break;
                    case "Number":
                        try {
                            values = String.valueOf(array.getInt(i));
                        } catch (Exception e) {
                            values = String.valueOf(array.getDouble(i));
                        }
                        break;
                    case "String":
                        values = array.getString(i);
                        break;
                }
                list.add(values);
            }
            return list;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 初始化每个LoopView选中的位置
     * @param selectValue
     */
    public void setSelectValue(String[] selectValue) {
        ReadableArray curArray =data;
        for(int i=0;i<selectValue.length;i++){
                for(int j=0;j<curArray.size();j++) {
                    if(curArray.getType(0).name().equals("Map")){
                        ReadableMap map = curArray.getMap(j);
                        ReadableMapKeySetIterator iterator = map.keySetIterator();
                        if (iterator.hasNextKey()) {
                            String value = iterator.nextKey();
                            if(value.equals(selectValue[i])){
                                loopViewArr.get(i).setSelectedPosition(j);
                                setData(i);
                                curArray = map.getArray(value);
                                ReturnData returnData = new ReturnData();
                                returnData.setItem(value);
                                returnData.setIndex(i);
                                curSelectedList.set(i, returnData);
                                break;
                            }
                        }
                }
                else{
                        if(selectValue[i].equals(arrayToList(curArray).get(j))){
                            loopViewArr.get(i).setSelectedPosition(j);
                            ReturnData returnData = new ReturnData();
                            returnData.setItem(selectValue[i]);
                            returnData.setIndex(i);
                            curSelectedList.set(i, returnData);
                            break;
                        }
                    }
            }

        }

    }

    public void setTextSize(float size){
        for(LoopView loopView:loopViewArr)
            loopView.setTextSize(size);
    }

    public void setTextColor(int color){
        for(LoopView loopView:loopViewArr)
            loopView.setTextColor(color);
    }

    public void setIsLoop(boolean isLoop) {
        for(LoopView loopView:loopViewArr)
            if(!isLoop)
                loopView.setNotLoop();
    }

    public int getViewHeight() {
        return height;
    }

    public ArrayList<ReturnData> getSelectedData() {
        return this.curSelectedList;
    }

    public void setOnSelectListener(OnSelectedListener listener) {
        this.onSelectedListener = listener;
    }
}