import { useMutation } from '@urql/vue'
import { NButton, NCheckbox, NPopconfirm, NSpace, NTable, useMessage } from 'naive-ui'
import { defineComponent, inject, reactive, type Ref } from 'vue'

import { Delete<@ data.capitalize_name @>Document } from '@/generated/graphql'
import { extractErrorMessage } from '@/plugins'

import { use<@ data.capitalize_name @> } from './<@ data.name @>-provider'

import type { API } from '/#/api'

export default defineComponent({
  name: '<@ data.capitalize_name @>Table',
  props: {
    <@ data.name @>: {
      type: Array as PropType<API.<@ data.capitalize_name @>[]>,
      default: () => []
    }
  },
  setup(props) {
    const message = useMessage()

    const { setOpen, setCurrentRow } = use<@ data.capitalize_name @>()

    const state = reactive({
      loading: false
    })

    const refetch = inject<() => void>('refetch')

    const todo = inject<Ref<string[]>>('todo')

    const { executeMutation: mutation, fetching } = useMutation(Delete<@ data.capitalize_name @>Document)

    const onDelete = async (item: API.<@ data.capitalize_name @>) => {
      if (state.loading) return
      state.loading = true

      try {
        const res = await mutation({ id: item.id })
        if (res.error) {
          const title = extractErrorMessage(res.error)
          message.error(title)
          return
        }

        if (res.data?.delete<@ data.capitalize_name @>) {
          message.success("删除成功")
          refetch?.()
        }
      } catch (error) {
        console.error(error)
      } finally {
        state.loading = false
      }
    }

    return () => (
      <>
        <NTable singleLine={false}>
          <thead>
            <tr>
              <th>
                <NCheckbox disabled />
              </th>
              <th>ID</th>
              <th>字段一</th>
              <th>字段二</th>
              <th>字段三</th>
              <th>字段四</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            {props.<@ data.name @>?.length === 0 ? (
              <tr>
                <td colspan='7'>
                  没有数据，请先添加
                </td>
              </tr>
            ) : (
              props.<@ data.name @>?.map(item => (
                <tr key={item.id}>
                  <td>
                    <NCheckbox disabled />
                  </td>
                  <td>{item.id}</td>
                  <td>字段一</td>
                  <td>字段二</td>
                  <td>字段三</td>
                  <td>字段四</td>
                  <td>
                    <NSpace align='center'>
                      <NButton
                        size='small'
                        onClick={() => {
                          setCurrentRow(item)
                          setOpen('edit')
                        }}
                      >
                        编 辑
                      </NButton>
                      <NPopconfirm
                        negativeText={null}
                        positiveText="确 认"
                        onPositiveClick={() => onDelete(item)}
                      >
                        {{
                          trigger: () => (
                            <NButton size='small' disabled={fetching.value} type='error'>
                              删 除
                            </NButton>
                          ),
                          default: () => "是否删除"
                        }}
                      </NPopconfirm>
                    </NSpace>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </NTable>
      </>
    )
  }
})
