//sort data 
export const SorttingData = ({ data, item, setState }: any) => {
    const manyTodos = [...data].sort((search1, search2) => {
        const item1 = search1[item].toLowerCase();
        const item2 = search2[item].toLowerCase();

        if (item1 < item2) {
            return -1;
        }
        if (item1 > item2) {
            return 1;
        }
        return 0;
    });
    setState(manyTodos);
};

export const sortElementsById = ({ data, item, setState }: any) => {
    const manyTodos = [...data].sort((search1, search2) => {
        const item1 = parseInt(search1[item]);
        const item2 = parseInt(search2[item]);

        if (item1 > item2) {
            return -1;
        }
        if (item1 < item2) {
            return 1;
        }
        return 0;
    });
    setState(manyTodos);
};

//search on input
export const handleSearchData = ({ data, item, setState }: any) => {
    setState(
        data.filter((search: any) =>
            Object.values(search).some(
                (field) =>
                    typeof field === 'string' &&
                    field.toLowerCase().includes(item?.toLowerCase()),
            )
        )
    )
}